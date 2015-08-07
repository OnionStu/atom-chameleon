pathM = require 'path'
desc = require './../utils/text-description'
fs = require 'fs-extra'
module.exports = UtilExtend =
	#检测是否为变色龙项目
	checkIsBSLProject:(filePath) ->
		if fs.existsSync(filePath)
			stats = fs.statSync(filePath)
			if stats.isFile()
				return false
			else
				config = pathM.join filePath,'appConfig.json'
				if fs.existsSync(config)
					statsConfig = fs.statSync(config)
					if statsConfig.isFile()
						return true
					else
						return false
				else
					return false
		else
			return false
