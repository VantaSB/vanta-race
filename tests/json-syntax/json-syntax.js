'use strict';

const fs = require( 'fs' ),
	process = require( 'process' ),
	glob = require( 'fast-glob' ),
	stripJsonComments = require( 'strip-json-comments' );

// Force synchronous output workaround for Node.js (it sometimes exits before completely printing everything)
process.stdout._handle.setBlocking( true ); // eslint-disable-line no-underscore-dangle

class JsonAssetsTest {
	constructor() {
		this.failedCount = 0; // Incremented by fail().

		// Populate tables by various load*() methods below
		this.knownItemCodes = new Set(); // [ itemCode1, itemCode2, ... ]
		this.craftableItemCodes = new Set();
		this.knownAssets = new Map(); // { filename1: assetData1, ... }

		this.knownLiquids = new Map(); // { liquidId: liquidData1, ... }
		this.knownMaterials = new Map(); // { materialId: materialData1, ... }
		this.knownMaterialsByName = new Map(); // { materialName: materialData1, ... }

		this.placeableMaterials = new Set(); // { materialId1, materialId2, ... }
	}

	// Run all checks
	runTest() {
		var totalAssetCount;

		this.loadMockedVanillaAssets();

		totalAssetCount = this.loadAssets();
		this.analyzeAssets();

		this.loadExceptionLists();
		this.loadCraftingRecipes();

		this.checkTreasurePools();
		this.checkTreeUnlocks();
		this.checkMonsters();

		console.log( totalAssetCount + ' JSON files checked with ' + this.failedCount + ' errors found\n' );
		return this.failedCount === 0;
	}

	// Print error and increment the number of failed tests
	fail( ...errorMessage ) {
		console.log( ...errorMessage );
		this.failedCount++;
	}

	// Partially load shortened info on vanilla assets
	loadMockedVanillaAssets() {
		[
			'data/vanilla_liquids.json',
			'data/vanilla_materials.json'
		].forEach( ( pathToMock ) => {
			var mocks = JSON.parse( fs.readFileSync( __dirname + '/' + pathToMock ).toString() );
			for ( var [ filename, data ] of mocks ) {
				this.knownAssets.set( filename, data );
			}
		} );
	}

	// Load all JSON assets
	loadAssets() {
		var directory = __dirname + '/../..',
			totalAssetCount = 0;

		this.findAssetFilenames( directory ).forEach( ( filename ) => {
			if ( ++totalAssetCount % 2500 === 0 && process.stdout.isTTY ) {
				// Progress bar
				process.stdout.write( totalAssetCount + ' ' );
			}

			var relaxedJsonString = fs.readFileSync( directory + '/' + filename ).toString();

			// Parse JSON
			var jsonString = this.sanitizeRelaxedJson( relaxedJsonString );
			var data;

			try {
				data = JSON.parse( jsonString );
			} catch ( error ) {
				this.fail( '\n', filename, this.addContextToJsonError( error, jsonString ) );
				return;
			}

			this.knownAssets.set( filename, data );
		} );

		// Completed progress bar
		console.log( '\n' );
		return totalAssetCount;
	}

	// Check asset contents after loading
	analyzeAssets() {
		for ( var [ filename, data ] of this.knownAssets ) {
			var filenameParts = filename.split( '.' ),
				fileExtension = filenameParts.pop(),
				patchedExtension = null;

			if ( fileExtension === 'patch' ) {
				// We don't have full vanilla assets here, so we can't apply patches completely,
				// but some parts of them may still be analyzed below.
				patchedExtension = filenameParts.pop();
			}

			// Add "sourceFilename" to all assets (for use in error messages).
			Object.defineProperty( data, 'sourceFilename', { value: filename } );

			// Ensure that description/shortdescription don't have non-closed color codes (e.g. ^yellow;).
			for ( var fieldName of [ 'description', 'shortdescription' ] ) {
				var fieldValue = data[fieldName];
				if ( fieldValue ) {
					var hasColor = false;
					for ( var match of fieldValue.matchAll( /\^([^;^]+);/g ) ) {
						var color = match[1].toLowerCase();
						hasColor = ( color !== 'reset' );
					}

					if ( hasColor ) {
						this.fail( '\n', filename, 'Missing ^reset; in ' + fieldName + ': ' + fieldValue );
					}
				}
			}

			// Remember if this is an item.
			var itemCode;
			if ( fileExtension === 'codex' && data.id ) {
				itemCode = data.id + '-codex';
			} else {
				itemCode = data.itemName || data.objectName;
			}

			if ( itemCode ) {
				if ( this.knownItemCodes.has( itemCode ) && itemCode !== 'weaponupgradeanvil2' ) {
					this.fail( '\n', filename, 'Duplicate item ID: ' + itemCode );
				}

				this.knownItemCodes.add( itemCode );

				if ( filename.startsWith( 'items/generic/produce' ) ) {
					// Produce items shouldn't cause a warning if used in unlocks of Agriculture nodes.
					this.craftableItemCodes.add( itemCode );
				}

				if ( data.materialId ) {
					this.placeableMaterials.add( data.materialId );
				}

				// Check if any of the racial scan descriptions are exactly the same as default scan text.
				for ( let [ key, value ] of Object.entries( data ) ) {
					if ( key.endsWith( 'Description' ) && value === data.description ) {
						this.fail( '\n', filename, 'Unnecessary key: ' + key + ': value is exactly the same as default scan text.' );
					}
				}

				// No more checks for items.
				continue;
			}

			// Remember if this is a liquid or material.
			if ( fileExtension === 'liquid' ) {
				this.knownLiquids.set( data.liquidId, data );
				continue;
			}

			if ( fileExtension === 'material' ) {
				this.knownMaterials.set( data.materialId, data );
				this.knownMaterialsByName.set( data.materialName, data );

				continue;
			}

			// Partially apply some patches.
			if ( !patchedExtension || ![ 'liquid', 'material' ].includes( patchedExtension ) ) {
				continue;
			}

			var dataToPatch = this.knownAssets.get( filename.replace( /\.patch$/, '' ) );
			if ( !dataToPatch ) {
				continue;
			}

			for ( let instruction of data ) {
				if ( instruction.op !== 'add' && instruction.op !== 'replace' ) {
					continue;
				}

				if ( instruction.path === '/interactions/-' ) {
					if ( !dataToPatch.interactions ) {
						dataToPatch.interactions = [];
					}
					dataToPatch.interactions.push( instruction.value );
				} else if ( instruction.path === '/liquidInteractions' ) {
					dataToPatch.liquidInteractions = instruction.value;
				} else if ( instruction.path === '/itemDrop' ) {
					dataToPatch.itemDrop = instruction.value;
				}
			}
		}
	}

	/**
	 * Get array of filenames of all JSON assets.
	 *
	 * @param {string} directory
	 * @return {string[]}
	 */
	findAssetFilenames( directory ) {
		var globOptions = {
			cwd: directory,
			ignore: [
				// Exclude everything that is not a JSON asset: images, documentation, examples, etc.
				'tests',
				'a_modders',
				'_previewimage',
				'**/*.gun', // legacy files (JSON, but are not loaded by the game)
				'**/*.{lua,png,xcf,wav,ogg,txt,md,tsx,aup,ico,tmx,pdn,zip,au,old,unused,disabled}'
			],
			caseSensitiveMatch: false
		};

		return glob.sync( '**', globOptions ).concat( [ '.metadata' ] );
	}

	/**
	 * Prepare the list of expected (ignored) errors, e.g. "unknown item" for vanilla items.
	 */
	loadExceptionLists() {
		// Having these item codes in .recipe files, extractions outputs, etc. won't be considered an error
		this.readAllLines( [
			'data/vanilla_items.txt'
		] ).forEach( ( itemCode ) => {
			this.knownItemCodes.add( itemCode );

			// We don't know if these items are craftable, so we assume that they are.
			this.craftableItemCodes.add( itemCode );
		} );

		// Having these item codes in unlocks of Research Tree won't be considered an error.
		/*this.readAllLines( [ 'data/expected_noncraftables_in_unlocks.txt' ] ).forEach( ( itemCode ) => {
			this.craftableItemCodes.add( itemCode );
		} );*/

		// These vanilla materials can be placed by player (using a block item)
		this.readAllLines( [
			'data/vanilla_materials.txt'
		] ).forEach( ( materialIdAsString ) => {
			this.placeableMaterials.add( parseInt( materialIdAsString ) );
		} );
	}

	// Check all recipe files for unknown inputs/outputs and remember which items are craftable
	loadCraftingRecipes() {
		// To help keep track of duplicate recipes
		var seenCraftingInputOutputs = new Set();

		// Check if any recipes have non-existent items
		for ( var [ filename, data ] of this.knownAssets ) {
			if ( !filename.endsWith( '.recipe' ) ) {
				continue;
			}

			var itemCodes = data.input.concat( [ data.output ] ).map( ( elem ) => elem.item || elem.name );
			itemCodes.forEach( ( itemCode ) => {
				if ( !this.knownItemCodes.has( itemCode ) ) {
					this.fail( filename, 'Unknown item in recipe: ' + itemCode );
				}
			} );

			this.craftableItemCodes.add( data.output.item || data.output.name ); // Vanta research
			var inputsOutputsId = data.input.concat( [
				Object.assign( { isOutput: 1 }, data.output )
			] ).map( ( elem ) => {
				let id = ( elem.item || elem.name ) + ':' + ( elem.count || 1 );

				if ( elem.parameters ) {
					id += ':' + JSON.stringify( Object.entries( elem.parameters ).sort() );
				}

				if ( elem.isOutput ) {
					id = '_Output<<<' + id + '>>>';
				}

				return id;
			} ).sort().join( ',' );

			if ( seenCraftingInputOutputs.has( inputsOutputsId ) ) {
				this.fail( filename, 'Two (or more) crafting recipes with the same inputs+outputs: ' + inputsOutputsId );
			}
			seenCraftingInputOutputs.add( inputsOutputsId );
		}
	}

	// Check if TreasurePools have unknown item codes.
	checkTreasurePools() {
		for ( var [ filename, data ] of this.knownAssets ) {
			if ( !filename.match( /\.treasurepools(|\.patch)$/ ) ) {
				continue;
			}

			if ( filename.endsWith( 'treasurepools' ) ) {
				for ( var poolDataSets of Object.values( data ) ) {
					poolDataSets.forEach( ( dataSet ) => {
						var poolData = dataSet[1];
						var poolElements = ( poolData.pool || [] ).concat( poolData.fill || [] );

						poolElements.forEach( ( elem ) => this.checkTreasurePoolElement( elem, filename ) );
					} );
				}
			} else if ( filename.endsWith( 'patch' ) ) {
				for ( var instruction of data ) {
					if ( instruction.op === 'add' && instruction.path.endsWith( '/pool/-' ) ) {
						this.checkTreasurePoolElement( instruction.value, filename );
					}
				}
			}
		}
	}

	// Check if 1 element of TreasurePool refers to unknown item.
	checkTreasurePoolElement( elem, sourceFilename ) {
		var itemCode = elem.item;
		if ( !itemCode ) {
			return;
		}

		if ( Array.isArray( itemCode ) ) {
			itemCode = itemCode[0];
		} else if ( itemCode.name ) {
			itemCode = itemCode.name;
		}

		itemCode = itemCode.replace( /-recipe$/, '' );
		if ( !this.knownItemCodes.has( itemCode ) ) {
			this.fail( sourceFilename, 'Unknown item in TreasurePool: ' + itemCode );
		}
	}

	checkTreeUnlocks() {
		for ( var treeFilename of [
			'interface/scripted/ex_research/researchFiles/vantaresearch.config'
		] ) {
			var treeConf = this.knownAssets.get( treeFilename ).researchTree;
			Object.values( Object.values( treeConf )[0] ).forEach( ( node ) => {
				if ( !node.unlocks ) {
					return;
				}

				for ( var itemCode of node.unlocks ) {
					if ( !this.knownItemCodes.has( itemCode ) ) {
						this.fail( treeFilename, 'Unknown item in research unlocks: ' + itemCode );
					} else if ( !this.craftableItemCodes.has( itemCode ) ) {
						this.fail( treeFilename, 'Non-craftable item in research unlocks: ' + itemCode );
					}
				}
			} );
		}
	}

	checkMonsters() {
		for ( var [ filename, data ] of this.knownAssets ) {
			if ( !filename.endsWith( '.monstertype' ) ) {
				continue;
			}

			var statusSettings = data.baseParameters.statusSettings;
			if ( !statusSettings ) {
				continue;
			}

			var stats = statusSettings.stats;
			var protection = ( stats.protection && stats.protection.baseValue );
			if ( protection && protection > 0 && protection < 1 ) {
				this.fail( filename, 'Monster has incorrect protection (between 0 and 1): ' +
					protection + ': should probably be ' + ( protection * 100 ) + '.' );
			}
		}
	}

	// Turn non-strict JSON into a string suitable for the parser
	sanitizeRelaxedJson( relaxedJson ) {
		var sanitizedJson = '',
			isInsideQuotes = false,
			prevChar = '';

		// JSON standardization doesn't allow comments, remove them
		relaxedJson = stripJsonComments( relaxedJson );

		// Remove both \r and BOM (byte order mark) symbols - the parser can't properly interpret them
		relaxedJson = relaxedJson.replace( /(\uFEFF|\r)/g, '' );

		// Replace "new line" or "tab" characters with "\n" and "\t" respectively
		[...relaxedJson].forEach( ( char ) => {
			// Non-escaped " means that this is start/end of a string.
			if ( char === '"' && prevChar !== '\\' ) {
				isInsideQuotes = !isInsideQuotes;
			} else if ( isInsideQuotes ) {
				switch ( char ) {
					case '\n':
						char = '\\n';
						break;
					case '\t':
						char = '\\t';
				}
			}

			sanitizedJson += char;
			prevChar = char;
		} );

		return sanitizedJson;
	}

	// Make errors from the parser readable by adding "text before/after the position of error".
	addContextToJsonError( exception, sourceCode ) {
		var errorMessage = exception.message;

		var match = errorMessage.match( 'at position ([0-9]+)' );
		if ( match ) {
			var symbolsToQuote = 100,
				position = parseInt( match[1] ),
				quoteBefore = sourceCode.slice( 0, position ).replace( /\s+/g, ' ' ),
				quoteAfter = sourceCode.slice( position ).replace( /\s+/g, ' ' );

			quoteBefore = quoteBefore.slice( -1 * symbolsToQuote );
			quoteAfter = quoteAfter.slice( 0, symbolsToQuote );

			errorMessage += '\n\t... ' + quoteBefore + '<SYNTAX ERROR>' + quoteAfter + ' ...';
		}

		return errorMessage;
	}

	readAllLines( filenames ) {
		var lines = [];
		filenames.forEach( ( filename ) => {
			var moreLines = fs.readFileSync( __dirname + '/' + filename ).toString().split( /[\r\n]+/ )
				.filter( function ( x ) {
					return x !== '' && !x.startsWith( '#' ) && !x.startsWith( '//' );
				} );
			lines.push( ...moreLines );
		} );
		return lines;
	}
}

// Run test
var test = new JsonAssetsTest();
process.exit( test.runTest() ? 0 : 1 );
