set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "blackhog"


"hi Example         guifg=NONE        guibg=NONE        gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE

" General colors
hi Normal           ctermfg=white        ctermbg=black        cterm=NONE
hi NonText          ctermfg=white       ctermbg=NONE        cterm=NONE

hi Cursor           ctermfg=black       ctermbg=white       cterm=reverse
hi LineNr           ctermfg=10    ctermbg=NONE        cterm=NONE

hi VertSplit        ctermfg=darkgray    ctermbg=darkgray    cterm=NONE
hi StatusLine       ctermfg=15       ctermbg=160    cterm=NONE
hi StatusLineNC     ctermfg=white        ctermbg=white    cterm=NONE  

hi Folded           ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Title            ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Visual           ctermfg=NONE        ctermbg=NONE        cterm=REVERSE

hi SpecialKey       ctermfg=NONE        ctermbg=NONE        cterm=NONE

hi WildMenu         ctermfg=black       ctermbg=yellow      cterm=NONE
hi PmenuSbar        ctermfg=black       ctermbg=white       cterm=NONE
hi Error            ctermfg=white       ctermbg=red         cterm=NONE     guisp=#FF6C60 " undercurl color
hi ErrorMsg         ctermfg=white       ctermbg=red         cterm=NONE
hi WarningMsg       ctermfg=white       ctermbg=red         cterm=NONE
hi LongLineWarning  ctermfg=NONE        ctermbg=NONE	      cterm=underline

" Message displayed in lower left, such as --INSERT--
hi ModeMsg          ctermfg=white       ctermbg=160        cterm=BOLD

hi CursorLine     guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
hi CursorColumn   guifg=NONE        guibg=#121212     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=BOLD
hi MatchParen     guifg=#f6f3e8     guibg=#857b6f     gui=BOLD      ctermfg=white       ctermbg=darkgray    cterm=NONE
hi Pmenu          guifg=#f6f3e8     guibg=#444444     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi PmenuSel       guifg=#000000     guibg=#cae682     gui=NONE      ctermfg=NONE        ctermbg=NONE        cterm=NONE
hi Search         guifg=NONE        guibg=#2F2F00     gui=underline ctermfg=NONE        ctermbg=NONE	      cterm=underline

" Syntax highlighting
hi Comment          ctermfg=8    ctermbg=NONE        cterm=NONE
hi String           ctermfg=10       ctermbg=NONE        cterm=NONE
hi Number           ctermfg=13     ctermbg=NONE        cterm=NONE

hi Keyword          ctermfg=160        ctermbg=NONE        cterm=NONE
hi PreProc          ctermfg=160        ctermbg=NONE        cterm=NONE
hi Conditional      ctermfg=12        ctermbg=NONE        cterm=NONE  " if else end

hi Todo             ctermfg=10         ctermbg=NONE        cterm=NONE
hi Constant         ctermfg=160        ctermbg=NONE        cterm=NONE

hi Identifier       ctermfg=160        ctermbg=NONE        cterm=NONE
hi Function         ctermfg=13       ctermbg=NONE        cterm=NONE
hi Type             ctermfg=12      ctermbg=NONE        cterm=NONE
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
hi rubyRegexp                  ctermfg=12          ctermbg=NONE      cterm=NONE
hi rubyRegexpDelimiter         ctermfg=12          ctermbg=NONE      cterm=NONE
hi rubyEscape                  ctermfg=12        ctermbg=NONE      cterm=NONE
hi rubyInterpolationDelimiter  ctermfg=12          ctermbg=NONE      cterm=NONE
hi rubyControl                 ctermfg=12          ctermbg=NONE      cterm=NONE  "and break, etc
hi rubyGlobalVariable          ctermfg=12          ctermbg=NONE      cterm=NONE  "yield
hi rubyStringDelimiter         ctermfg=160        ctermbg=NONE      cterm=NONE
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
hi link javaScopeDecl         Identifier 
hi link javaCommentTitle      javaDocSeeTag 
hi link javaDocTags           javaDocSeeTag 
hi link javaDocParam          javaDocSeeTag 
hi link javaDocSeeTagParam    javaDocSeeTag 
hi javaDocSeeTag              ctermfg=darkgray    ctermbg=NONE        cterm=NONE
hi javaDocSeeTag              ctermfg=darkgray    ctermbg=NONE        cterm=NONE

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

" Special for CSharp
hi  link csXmlTag             Keyword      
