" ir_black color scheme
" More at: http://blog.infinitered.com


" ********************************************************************************
" Standard colors used in all ir_black themes:
" Note, x:x:x are RGB values
"
"  normal: #f6f3e8
" 
"  string: #A8FF60  168:255:96                   
"    string inner (punc, code, etc): #00A0A0  0:160:160
"  number: #FF73FD  255:115:253                 
"  comments: #7C7C7C  124:124:124
"  keywords: #96CBFE  150:203:254             
"  operators: white
"  class: #FFFFB6  255:255:182
"  method declaration name: #FFD2A7  255:210:167
"  regular expression: #E9C062  233:192:98
"    regexp alternate: #FF8000  255:128:0
"    regexp alternate 2: #B18A3D  177:138:61
"  variable: #C6C5FE  198:197:254
"  
" Misc colors:
"  red color (used for whatever): #FF6C60   255:108:96 
"     light red: #FFB6B0   255:182:176
"
"  brown: #E18964  good for special
"
"  lightpurpleish: #FFCCFF
" 
" Interface colors:
"  background color: black
"  cursor (where underscore is used): #FFA560  255:165:96
"  cursor (where block is used): white
"  visual selection: #1D1E2C  
"  current line: #151515  21:21:21
"  search selection: #07281C  7:40:28
"  line number: #3D3D3D  61:61:61


" ********************************************************************************
" The following are the preferred 16 colors for your terminal
"           Colors      Bright Colors
" Black     #4E4E4E     #7C7C7C
" Red       #FF6C60     #FFB6B0
" Green     #A8FF60     #CEFFAB
" Yellow    #FFFFB6     #FFFFCB
" Blue      #96CBFE     #B5DCFE
" Magenta   #FF73FD     #FF9CFE
" Cyan      #C6C5FE     #DFDFFE
" White     #EEEEEE     #FFFFFF


" ********************************************************************************
set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "blackhog"


"hi Example         guifg=NONE        guibg=NONE        gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

" General colors
hi Normal           ctermfg=white        ctermbg=black        cterm=NONE
hi NonText          ctermfg=black       ctermbg=NONE        cterm=NONE

hi Cursor           ctermfg=black       ctermbg=white       cterm=reverse
hi LineNr           ctermfg=13    ctermbg=NONE        cterm=NONE

hi VertSplit        ctermfg=darkgray    ctermbg=darkgray    cterm=NONE
hi StatusLine       ctermfg=15       ctermbg=160    cterm=NONE
hi StatusLineNC     ctermfg=15        ctermbg=160    cterm=NONE  

hi Folded           ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Title            ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Visual           ctermfg=NONE        ctermbg=NONE        cterm=REVERSE

hi SpecialKey       ctermfg=NONE        ctermbg=NONE        cterm=NONE

hi WildMenu         ctermfg=black       ctermbg=yellow      cterm=NONE
hi PmenuSbar        ctermfg=black       ctermbg=white       cterm=NONE
"hi Ignore          guifg=gray        guibg=black       gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

hi Error            ctermfg=white       ctermbg=red         cterm=NONE     guisp=#FF6C60 " undercurl color
hi ErrorMsg         ctermfg=white       ctermbg=red         cterm=NONE
hi WarningMsg       ctermfg=white       ctermbg=red         cterm=NONE
hi LongLineWarning  ctermfg=NONE        ctermbg=NONE	      cterm=underline

" Message displayed in lower left, such as --INSERT--
hi ModeMsg          ctermfg=white       ctermbg=160        cterm=BOLD

if version >= 700 " Vim 7.x specific colors
  hi CursorLine     guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
  hi CursorColumn   guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
  hi MatchParen     guifg=#f6f3e8     guibg=#857b6f     gui=BOLD      ctermfg=white       ctermbg=darkgray    cterm=NONE
  hi Pmenu          guifg=#f6f3e8     guibg=#444444     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
  hi PmenuSel       guifg=#000000     guibg=#cae682     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
  hi Search         guifg=NONE        guibg=#2F2F00     gui=underline ctermfg=NONE        ctermbg=NONE	      cterm=underline
endif

" Syntax highlighting
hi Comment          ctermfg=8    ctermbg=NONE        cterm=NONE
hi String           ctermfg=10       ctermbg=NONE        cterm=NONE
hi Number           ctermfg=13     ctermbg=NONE        cterm=NONE

hi Keyword          ctermfg=160        ctermbg=NONE        cterm=NONE
hi PreProc          ctermfg=160        ctermbg=NONE        cterm=NONE
hi Conditional      ctermfg=21        ctermbg=NONE        cterm=NONE  " if else end

hi Todo             ctermfg=10         ctermbg=NONE        cterm=NONE
hi Constant         ctermfg=160        ctermbg=NONE        cterm=NONE

hi Identifier       ctermfg=160        ctermbg=NONE        cterm=NONE
hi Function         ctermfg=13       ctermbg=NONE        cterm=NONE
hi Type             ctermfg=21      ctermbg=NONE        cterm=NONE
hi Statement        ctermfg=160   ctermbg=NONE        cterm=NONE

hi Special          ctermfg=160       ctermbg=NONE        cterm=NONE
hi Delimiter        ctermfg=cyan        ctermbg=NONE        cterm=NONE
hi Operator         ctermfg=white       ctermbg=NONE        cterm=NONE

hi Directory        ctermfg=white       ctermbg=black        cterm=NONE

hi link Character       Constant
hi link Boolean         Constant
hi link Float           Number
hi link Repeat          Statement
hi link Label           Statement
hi link Exception       Statement
hi link Include         PreProc
hi link Define          PreProc
hi link Macro           PreProc
hi link PreCondit       PreProc
hi link StorageClass    Type
hi link Structure       Type
hi link Typedef         Type
hi link Tag             Special
hi link SpecialChar     Special
hi link SpecialComment  Special
hi link Debug           Special


" Special for Ruby
hi rubyRegexp                  ctermfg=17          ctermbg=NONE      cterm=NONE
hi rubyRegexpDelimiter         ctermfg=17          ctermbg=NONE      cterm=NONE
hi rubyEscape                  ctermfg=21        ctermbg=NONE      cterm=NONE
hi rubyInterpolationDelimiter  ctermfg=21          ctermbg=NONE      cterm=NONE
hi rubyControl                 ctermfg=21          ctermbg=NONE      cterm=NONE  "and break, etc
hi rubyGlobalVariable          ctermfg=21          ctermbg=NONE      cterm=NONE  "yield
hi rubyStringDelimiter         ctermfg=160        ctermbg=NONE      cterm=NONE
"rubyInclude
"rubySharpBang
"rubyAccess
"rubyPredefinedVariable
"rubyBoolean
"rubyClassVariable
"rubyBeginEnd
"rubyRepeatModifier
"hi link rubyArrayDelimiter    Special  " [ , , ]
"rubyCurlyBlock  { , , }

hi link rubyClass             Keyword 
hi link rubyModule            Keyword 
hi link rubyKeyword           Keyword 
hi link rubyOperator          Operator
hi link rubyIdentifier        Identifier
hi link rubyInstanceVariable  Identifier
hi link rubyGlobalVariable    Identifier
hi link rubyClassVariable     Identifier
hi link rubyConstant          Type  


" Special for Java
" hi link javaClassDecl    Type
hi link javaScopeDecl         Identifier 
hi link javaCommentTitle      javaDocSeeTag 
hi link javaDocTags           javaDocSeeTag 
hi link javaDocParam          javaDocSeeTag 
hi link javaDocSeeTagParam    javaDocSeeTag 

hi javaDocSeeTag              ctermfg=darkgray    ctermbg=NONE        cterm=NONE
hi javaDocSeeTag              ctermfg=darkgray    ctermbg=NONE        cterm=NONE
"hi javaClassDecl             guifg=#CCFFCC     guibg=NONE        gui=NONE      ctermfg=white       ctermbg=NONE        cterm=NONE


" Special for XML
hi link xmlTag          Keyword 
hi link xmlTagName      Conditional 
hi link xmlEndTag       Identifier 


" Special for HTML
hi link htmlTag         Keyword 
hi link htmlTagName     Conditional 
hi link htmlEndTag      Identifier 


" Special for Javascript
hi link javaScriptNumber      Number 


" Special for Python
"hi  link pythonEscape         Keyword      


" Special for CSharp
hi  link csXmlTag             Keyword      


" Special for PHP
