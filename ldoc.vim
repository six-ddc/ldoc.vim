" http://vimdoc.sourceforge.net/htmldoc/usr_41.html

"""""""""""""""""""""""""""""
" 工具函数
"""""""""""""""""""""""""""""
function! s:warnMsg(msg)
	echohl WarningMsg
	echo a:msg
	echohl None
endfunction

" 插件重复性加载的冲突检测
if exists("loaded_ldoc_ddc")
	call s:warnMsg("Ldoc Already Loaded!")
	finish
endif
let loaded_ldoc_ddc = 1

"""""""""""""""""""""""""""""
" 全局注释变量
"""""""""""""""""""""""""""""
if !exists("g:ldoc_startBeginCommentTag")
	let g:ldoc_startBeginCommentTag = "----------------------------------------"
endif
if !exists("g:ldoc_startEndCommentTag")
	let g:ldoc_startEndCommentTag   = "----------------------------------------"
endif
if !exists("g:ldoc_startNoteCommentTag")
	let g:ldoc_startNoteCommentTag = "--- "
endif
if !exists("g:ldoc_startFlagCommentTag")
	let g:ldoc_startFlagCommentTag = "-- "
endif


"""""""""""""""""""""""""""""
" 全局标记状态变量
"""""""""""""""""""""""""""""
if !exists("g:ldoc_flagAuthor")
	let g:ldoc_flagAuthor = "@author "
endif
if !exists("g:ldoc_flagType")
	let g:ldoc_flagType = "@type "
endif
if !exists("g:ldoc_flagParam")
	let g:ldoc_flagParam = "@param "
endif
if !exists("g:ldoc_flagReturn")
	let g:ldoc_flagReturn = "@return "
endif

"""""""""""""""""""""""""""""
" 写入函数
" 详细参见append函数,参数2可直接传入列表
"""""""""""""""""""""""""""""
function! s:writeToNextLine(str)
	call append(line("."), a:str)
endfunction
function! s:writeToPrevLine(str)
	call append(line(".")-1, a:str)
endfunction

"""""""""""""""""""""""""""""
" 模块的注释
"""""""""""""""""""""""""""""
function! <SID>ldoc_moduleComment()
	if !exists("g:ldoc_authorName")
		let g:ldoc_authorName = input("输入作者名(忽略将使用当前用户名):")
	endif
	if(strlen(g:ldoc_authorName) == 0)
		let l:whoami = system("whoami")
		let g:ldoc_authorName = substitute(l:whoami, '\n', "", "")
		echo g:ldoc_authorName
	endif
	let l:moduleDesc = input("输入模块的简单说明(可直接回车,稍后填写):")
	mark l
	let l:writeText = [g:ldoc_startBeginCommentTag]
	let l:markJump = 0
	let l:str = g:ldoc_startNoteCommentTag
	if(strlen(l:moduleDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:moduleDesc
	endif
	call add(l:writeText, l:str)
	call add(l:writeText, g:ldoc_startFlagCommentTag . g:ldoc_flagAuthor . g:ldoc_authorName)
	call add(l:writeText, g:ldoc_startEndCommentTag)
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText) + 1) . "G$"
	else
		exec "normal 'l"
	endif
endfunction

"""""""""""""""""""""""""""""
" 类型的注释
"""""""""""""""""""""""""""""
function! <SID>ldoc_typeComment()
	let l:curLineStr = getline(line("."))
	let l:typeNameList = matchlist(l:curLineStr, 'local[ \t]\+\([a-zA-Z0-9_]\+\)[ \t]\+')
	if(len(l:typeNameList) < 2)
		call s:warnMsg("获取type失败,call jncpp@qq.com")
		return
	endif
	let l:typeName = l:typeNameList[1]
	let l:typeDesc = input("输入类型的简单说明(可直接回车,稍后填写):")
	mark l
	let l:writeText = []
	let l:markJump = 0
	let l:str = g:ldoc_startNoteCommentTag
	if(strlen(l:typeDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:typeDesc
	endif
	call add(l:writeText, l:str)
	call add(l:writeText, g:ldoc_startFlagCommentTag . g:ldoc_flagType . l:typeName)
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText)) . "G$"
	else
		exec "normal 'l"
	endif
endfunction

"""""""""""""""""""""""""""""
" 函数的注释
"""""""""""""""""""""""""""""
function! <SID>ldoc_functionComment()
	let l:curLineStr = getline(line("."))
	let l:paramList = matchlist(l:curLineStr, 'function[ \t]\+\([a-zA-Z0-9_.:]\+\)[ \t]*(\([a-zA-Z0-9_, \t\.]*\))')
	if(len(l:paramList) >= 2)
	else
		let l:paramList = matchlist(l:curLineStr, '\([a-zA-Z0-9_]\+\)[ \t]*=[ \t]*function[ \t]*(\([a-zA-Z0-9_, \t\.]*\))')
		if(len(l:paramList) < 2)
			call s:warnMsg("获取函数失败,call jncpp@qq.com")
			return
		endif
	endif
	let l:funcName = l:paramList[1]
	if(len(l:paramList) > 3)
		let l:paramList = split(l:paramList[2], '[ \t]*,[ \t]*')
		let l:paramList2 = []
		for l:ele in l:paramList
			call add(l:paramList2, substitute(l:ele, '[ \t]+', "", ""))
		endfor
	endif
	mark l
	let l:funcDesc = input("输入函数[" . l:funcName . "]的简单说明(可直接回车,稍后填写):")
	let l:writeText = []
	let l:str = g:ldoc_startNoteCommentTag
	let l:markJump = 0
	if(strlen(l:funcDesc) == 0)
		let l:markJump = 1
	else
		let l:str = l:str . l:funcDesc
	endif
	call add(l:writeText, l:str)
	for l:ele in l:paramList2
		let l:str = g:ldoc_startFlagCommentTag . g:ldoc_flagParam . l:ele
		let l:paramDesc = input("输入参数[" . l:ele . "]的简单说明:")
		if(strlen(l:paramDesc) > 0)
			let l:str = l:str . "\t" . l:paramDesc
		endif
		call add(l:writeText, l:str)
	endfor
	call s:writeToPrevLine(l:writeText)
	if(l:markJump == 1)
		exec "normal " . (line(".") - len(l:writeText)) . "G$"
	else
		exec "normal 'l"
	endif
endfunction


"""""""""""""""""""""""""""""
" 快捷键映射
"""""""""""""""""""""""""""""
command! -nargs=0 LdocM :call <SID>ldoc_moduleComment()
command! -nargs=0 LdocT :call <SID>ldoc_typeComment()
command! -nargs=0 LdocF :call <SID>ldoc_functionComment()
