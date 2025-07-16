function init()
	storage.sign = config.getParameter("sign", "room")
	animator.setAnimationState("signState", storage.sign)
end
