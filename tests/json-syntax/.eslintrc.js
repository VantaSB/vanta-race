'use strict';

module.exports = {
	env: {
		node: true,
		es2021: true
	},
	extends: [
		'wikimedia',
		'wikimedia/node',
		'wikimedia/language/es2021'
	],
	parserOptions: {
		ecmaVersion: 12
	},
	rules: {
		'no-console': 'off',
		'no-process-exit': 'off',
		'prefer-const': 'off',
		'no-loop-func': 'off',
		'array-bracket-spacing': 'off',
		'computed-property-spacing': 'off',
		'max-len': 'off',
		'no-var': 'off'
	}
}
