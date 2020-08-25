\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{Bachelorarbeit}[2019/01/21 HfTL Thesis Template]

% ----------------------------------------------------
% define language options for automated translation of specific pages
\RequirePackage{etoolbox}
\preto\@classoptionslist{ngerman,}
\newcommand{\@thesisLanguage}{UKenglish,USenglish,main=ngerman}
\DeclareOption{ngerman}{\renewcommand{\@thesisLanguage}{UKenglish,USenglish,main=ngerman}}
\DeclareOption{UKenglish}{\renewcommand{\@thesisLanguage}{ngerman,USenglish,main=UKenglish}}
\DeclareOption{USenglish}{\renewcommand{\@thesisLanguage}{ngerman,UKenglish,main=USenglish}}
\DeclareOption{english}{\renewcommand{\@thesisLanguage}{ngerman,main=english}}

\newif\if@numeric\@numerictrue
\newif\if@authoryear
\newif\if@alphabetic
\DeclareOption{numeric}{
	\@numerictrue%
	\@authoryearfalse%
	\@alphabeticfalse%
}
\DeclareOption{authoryear}{
	\@numericfalse%
	\@authoryeartrue%
	\@alphabeticfalse%
}
\DeclareOption{alphabetic}{
	\@numericfalse%
	\@authoryearfalse%
	\@alphabetictrue%
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrbook}}
\ProcessOptions\relax
\PackageInfo{Bachelorarbeit}{Using language: \@thesisLanguage}
% ----------------------------------------------------

% ----------------------------------------------------
% Use scrbook as base document class
\LoadClass[
a4paper,
12pt,
toc=flat,
toc=listof,
toc=bibliography,
parskip=full,
\@thesisLanguage,
titlepage=firstiscover,
twoside=false,
numbers=noenddot,
DIV=13,
captions=figurebelow,
captions=tableabove
]
{scrbook}

% ----------------------------------------------------
% Load required packages
\RequirePackage[utf8]{inputenc} %Enable UTF-8 support
\RequirePackage{scrhack} % fixes listings and float environments for KOMA Classes
\RequirePackage{xifthen} %For internal use
\RequirePackage{XCharter} % XCharter as default serif font (Text)
\RequirePackage[defaultsans]{opensans} % OpenSans as default sans serif font (headings)
\RequirePackage[scale=.95]{sourcecodepro} % Source Code Pro as default monospace font (Code)
\RequirePackage[T1]{fontenc} % Select font encoding
\RequirePackage[\@thesisLanguage]{babel} %Package for label translation and hyphenation settings
\if@numeric%
	\PassOptionsToPackage{
		style=numeric-comp,%
		sorting=none%
	}{biblatex}%
\else%
\if@authoryear%
	\PassOptionsToPackage{
		style=authoryear-comp,%
		uniquename=init
	}{biblatex}%
\else%
\if@alphabetic%
	\PassOptionsToPackage{
		style=alphabetic%
	}{biblatex}%
\fi\fi\fi%

\RequirePackage[
	backref,
	maxbibnames=5,
	toc=bib
]{biblatex}

\@ifpackagelater{biblatex}{2016/03/01}{%
	\ExecuteBibliographyOptions{
		giveninits=true%
	}%
}{%
	\ExecuteBibliographyOptions{%
		firstinits=true%
	}%
}

\RequirePackage[final]{graphicx} % Needed in order to include graphics
\RequirePackage[svgnames]{xcolor} % support for colors. See https://www.latextemplates.com/svgnames-colors for available ones

\RequirePackage{csquotes} % Language dependend quotation marks with \enquote{text}
\RequirePackage{ragged2e} % more advanced text layout

\RequirePackage{amsmath} %For math environents
\RequirePackage{multirow} %Allows merging table cells
\RequirePackage{longtable} %For tables spanning multiple pages
\RequirePackage{tabularx}
\RequirePackage{needspace, enumitem}
\RequirePackage{booktabs}
% nicer looking table rules like \toprule or \botomrule

\RequirePackage{microtype}
\RequirePackage[headsepline,footsepline,automark,plainheadsepline,plainfootsepline]{scrlayer-scrpage}


\RequirePackage[bookmarks,unicode]{hyperref}
\RequirePackage[acronym,shortcuts,toc,translate=babel]{glossaries}

%\RequirePackage{Ressources/glossaries-style-acronymlist}
% ----------------------------------------------------

% ----------------------------------------------------
% Settings for document layout
\clubpenalty = 10000				% prevent single lines at the beginning of a paragraph (Schusterjungen)
\widowpenalty = 10000				% prevent single lines at the end of a paragraph (Hurenkinder)
\displaywidowpenalty = 10000		%

% ----------------------------------------------------
% Definition of the glossarie style "acronymlist"
\newlength{\@thislen}
\newlength{\@tmplen}

\newcommand{\@updatelabeliflonger}[1]{
	\ifdim\@tmplen>\@thislen%
	\@thislen=\@tmplen%
	\edef\longestacrlabel{\glsentryname{\thislabel}}%
	\fi
}
\renewcommand*\glspostdescription{\dotfill}
\newcommand{\setlongestacrlabel}[1]{
	\newcommand{\longestacrlabel}{}
	\ifthenelse{\isempty{#1}}{
		% #1 is empty	
		\ifcsdef{@glsref@\acronymtype}{
			\forglsentries[\acronymtype]{\thislabel}
			{\xifinlistcs{\thislabel}{@glsref@\acronymtype}{%
					\settowidth{\@tmplen}%
					{\glsentryname{\thislabel}}%
					\@updatelabeliflonger{\thislabel}%
				}{}
			}%
		}{\@gls@noref@warn{\acronymtype}}		
	}{
		\renewcommand{\longestacrlabel}{#1}
	}
}
\newcommand{\acrlabelfont}[1]{\textbf{#1}}
\newglossarystyle{acronymlist}{%	
	\setglossarystyle{list}	
	
	
	\renewenvironment{theglossary}%	
	{	\ifdef{\longestacrlabel}%
		{\relax}{%	  
			\setlongestacrlabel{}
		}
		\raggedright\begin{list}{}
			{\settowidth{\labelwidth}{\acrlabelfont{\longestacrlabel}}
				\addtolength{\labelwidth}{1em}
				\setlength{\leftmargin}{\labelwidth}
				\setlength{\itemsep}{-.1em}
				\addtolength{\leftmargin}{\labelsep}						
		}}{\end{list}}%
	
	\renewcommand*{\glossentry}[2]{%
		\item[\acrlabelfont{\glsentryitem{##1}%
			\glstarget{##1}{\glossentryname{##1}}\hfill}]
		\glossentrydesc{##1}\glspostdescription\space ##2}%
} 

\setglossarystyle{acronymlist}
% ----------------------------------------------------

% ----------------------------------------------------
% Sets the layout of page footer and header
\pagestyle{scrheadings}
\clearpairofpagestyles
\renewcommand\chaptermarkformat{\chaptername\space\thechapter:\space}
\lofoot[\@author]{\@author}
\ofoot[\pagemark]{\pagemark}
\ohead[\headmark]{\headmark}
\setkomafont{pageheadfoot}{\footnotesize}
% ----------------------------------------------------


% ----------------------------------------------------
% Provide localized captions and renames labes
\addto\captionsngerman{
	\renewcommand{\acronymname}{Abkürzungsverzeichnis} % for some reason providecaptionname does not work for renaming the acronyms, so using the Babel way here
}
\addto\captionsUKenglish{
	\renewcommand{\acronymname}{List of Abbreviations} % for some reason providecaptionname does not work for renaming the acronyms, so using the Babel way here
}
\addto\captionsUSenglish{
	\renewcommand{\acronymname}{List of Abbreviations} % for some reason providecaptionname does not work for renaming the acronyms, so using the Babel way here
}
\addto\captionsenglish{
	\renewcommand{\acronymname}{List of Abbreviations} % for some reason providecaptionname does not work for renaming the acronyms, so using the Babel way here
}

\AtBeginDocument{%
	\providecaptionname{ngerman}{\lstlistlistingname}{Quellcodeverzeichnis} %rename list of listings
	\providecaptionname{ngerman}{\lstlistingname}{Quellcode} %rename label of listings
	
	\newcaptionname{ngerman}{\firstreviewercaption}{Erstprüfer}
	\newcaptionname{ngerman}{\secondreviewercaption}{Zweitprüfer}
	\newcaptionname{ngerman}{\submittedcaption}{Vorgelegt am}
	\newcaptionname{ngerman}{\topiccaption}{Thema}
	\newcaptionname{ngerman}{\submittedbycaption}{Vorgelegt von}
	\newcaptionname{ngerman}{\dateofbirthcaption}{Geboren am}
	\newcaptionname{ngerman}{\placeofbirthcaption}{Geboren in}
	
	\newcaptionname{ngerman}{\declarationofauthorshipcaption}{Selbstständigkeitserklärung}

	\newcaptionname{ngerman}{\declarationofauthorshipstatementonecaption}{Hiermit erkläre ich, \theThesisAuthor, dass die von mir an der \textit{\theUniversity} eingereichte Abschlussarbeit zum Thema}
	\newcaptionname{ngerman}{\declarationofauthorshipstatementtwocaption}{selbstständig verfasst wurde und von mir keine anderen als die angegebenen Quellen und Hilfsmittel verwendet wurden.}
	\newcaptionname{ngerman}{\dencaption}{den }

	\providecaptionname{british,UKenglish,USenglish,american}{\contentsname}{Table of Contents}% For some reason, all english variants have to be declared here
	\providecaptionname{USenglish,UKenglish}{\lstlistlistingname}{List of Sourcecodes} %rename list of listings
	\providecaptionname{USenglish,UKenglish}{\lstlistingname}{Sourcecode} %rename label of listings
	
	\newcaptionname{USenglish,UKenglish}{\firstreviewercaption}{First reviewer}
	\newcaptionname{USenglish,UKenglish}{\secondreviewercaption}{Second reviewer}
	\newcaptionname{USenglish,UKenglish}{\submittedcaption}{Submitted on}
	\newcaptionname{USenglish,UKenglish}{\topiccaption}{Topic}
	\newcaptionname{USenglish,UKenglish}{\submittedbycaption}{Submitted by}
	\newcaptionname{USenglish,UKenglish}{\dateofbirthcaption}{Born on}
	\newcaptionname{USenglish,UKenglish}{\placeofbirthcaption}{Born in}
	
	\newcaptionname{USenglish,UKenglish}{\declarationofauthorshipcaption}{Declaration of Authorship}
	\newcaptionname{USenglish,UKenglish}{\declarationofauthorshipstatementonecaption}{I, \theThesisAuthor, hereby declare that this thesis, submitted at \textit{\theUniversity}, with the topic}
	\newcaptionname{USenglish,UKenglish}{\declarationofauthorshipstatementtwocaption}{was composed indepently and no sources or tools other than those indicated were used.}
	\newcaptionname{USenglish,UKenglish}{\dencaption}{}
}

\DefineBibliographyStrings{ngerman}{%
	andothers = {{et\,al\adddot}}, % 'et al.' instead of 'u.a.'
	backrefpage = {{zitiert auf Seite}},%
	backrefpages = {{zitiert auf den Seiten}},%
	bibliography = {Literaturverzeichnis}
}
% ----------------------------------------------------

% ----------------------------------------------------
% Slight modifications to the bibliography:
% Only print URL, if DOI not present (https://tex.stackexchange.com/questions/424774/print-url-only-if-doi-not-present)
\renewbibmacro*{doi+eprint+url}{%
	\printfield{doi}%
	\newunit\newblock%
	\iftoggle{bbx:eprint}{%
		\usebibmacro{eprint}%
	}{}%
	\newunit\newblock%
	\iffieldundef{doi}{%
		\usebibmacro{url+urldate}}%
	{}%
}

% Unify style of title
\DeclareFieldFormat[inproceedings,article,misc]{title}{\textit{#1}}
% ----------------------------------------------------

\AtEndPreamble{%
% ----------------------------------------------------
% Use prettier colors for PGFPlots	
	\@ifpackageloaded{pgfplots}{%
		\pgfplotsset{
			cycle list name=exotic,
			compat=newest
		}
	}{}
% ----------------------------------------------------
% Settings for siunitx package
	\@ifpackageloaded{siunitx}{%
		\sisetup{
			per-mode=fraction,
			binary-units=true
		}
% ----------------------------------------------------
}{}
}

% ----------------------------------------------------
% Define settings and additional languages for listings package
\AtEndPreamble{%
	\@ifpackageloaded{listings}{%
		\lstset{%
			breaklines=true,%
			showstringspaces=false,%
			frame=l,%
			xleftmargin=15pt,%
			xrightmargin=15pt,%
			basicstyle=\ttfamily\footnotesize,%
			stepnumber=1,%
			%showtabs=true,
			tabsize=4,%
			numbers=left,%
			keywordstyle=\bfseries\color{blue},% keyword style
			commentstyle=\color{DarkGreen},% comment style
			stringstyle=\color{DarkMagenta},% string literal style,
		}%
		\lstset{literate=%
			{Ö}{{\"O}}1%
			{Ä}{{\"A}}1%
			{Ü}{{\"U}}1%
			{ß}{{\ss}}1%
			{ü}{{\"u}}1%
			{ä}{{\"a}}1%
			{ö}{{\"o}}1%
		}%	
		\lstdefinelanguage{latex}{%
			language = tex,%
			morekeywords = {%
				alert,%
				alertArrow,%
				midrule,%
				subsection,%
				toprule,%
				begin,%
				includegraphics,%
				caption,%
				label,%
				\%%
			}%
		}%
		\lstdefinelanguage{JSON}{%
			basicstyle=\color{black}\bfseries,%
			keywords={cmd, status, attributes},%
			keywordstyle=\color{blue}\bfseries,%
			ndkeywords={sessions,sessionId, sessionName, addressUri, currentTime, contentStatus, info, videoformat, quality, newQuality, user, pubID, pass, realm, pcscf, wsuri},%
			ndkeywordstyle=\color{cyan}\bfseries,%
			stringstyle=\color{black}\ttfamily,%
			morestring=[b]',%
			morestring=[b]"%
		}%
		\lstdefinelanguage{JavaScript}{%
			keywords={typeof, new, true, false, catch, function, return, null, catch, switch, var, if, in, while, do, else, case, break},%
			keywordstyle=\color{blue}\bfseries,%
			ndkeywords={class, export, boolean, throw, implements, import, this},%
			ndkeywordstyle=\color{darkgray}\bfseries,%
			identifierstyle=\color{black},%
			sensitive=false,%
			comment=[l]{//},%
			morecomment=[s]{/*}{*/},%
			commentstyle=\color{purple}\ttfamily,%
			stringstyle=\color{cyan}\ttfamily,%
			morestring=[b]',%
			morestring=[b]"%
		}%
		\lstdefinelanguage{bash}%
		{keywords={for, if, else, then, fi, echo, case, in,%
				elif, esac, for, do, done, tar, while, until, shift,%
				mv, mkdir, ;;, \$\#, \$1, \$2},%
			string=[d]{"},%
			% comment={\#},%
			sensitive=false,%
			basicstyle=\ttfamily%
		}%
		\lstdefinestyle{csharp}{language=[Sharp]C}%
	}{}%
}%

% ----------------------------------------------------

% ----------------------------------------------------
%Set default Graphicspath to "Graphics"
\graphicspath{{./Graphics/}}
% ----------------------------------------------------


% ----------------------------------------------------
% Make space before and after chapter title smaller
\renewcommand*{\chapterheadstartvskip}{%
	\vspace*{2.3\baselineskip}%
}%
\renewcommand*{\chapterheadendvskip}{%
	\vspace{1.725\baselineskip
		\@plus .115\baselineskip \@minus .192\baselineskip}%
}%
% ----------------------------------------------------

% ----------------------------------------------------
% Use the same font for the labels of the labeling environment as for the description labels
\setkomafont{labelinglabel}{
	\usekomafont{descriptionlabel}
}

% ----------------------------------------------------


% ----------------------------------------------------
% Settings for hyperref package
\AtBeginDocument{
	\subject{\theDocumentKind\space\theForDegree}
	\hypersetup
	{
	 pdftitle = {\@title},
	 pdfsubject = {\@subject},
	 pdfauthor = {\@author},
	 unicode = {true},
	 pdfcreator={LaTeX with hyperref package using HfTL Thesis Template by Martin Meszaros},
	%  bookmarks = {true},
	 bookmarksopen = {true},
	 hidelinks
	}
}
% ----------------------------------------------------

% ----------------------------------------------------
% Misc. design adjustments
\renewcommand{\arraystretch}{1.2} % add more padding to table cells

\setcounter{tocdepth}{4} 
\setcounter{secnumdepth}{4} 

% ----------------------------------------------------
% definition of the aligneddesription environment
\SetLabelAlign{parright}{\parbox[t]{\labelwidth}{\raggedleft#1}}
\newenvironment{aligneddescription}[1][mycoolitem]
{
	\needspace{2\baselineskip}
	\begin{description}[labelwidth=\widthof{\descriptionlabel{#1}},%
		leftmargin =\dimexpr\labelwidth+\labelsep\relax,labelsep=1em,style=multiline,align=parright]}
	{\end{description}\needspace{2\baselineskip}%
}
% ----------------------------------------------------

% ----------------------------------------------------
% The \inserthftllogo command with embedded logo
\newcommand{\inserthftllogo}[1][!]{
\resizebox{#1}{!}{
	\begin{picture}(116.8,45.8)
	\pdfliteral {
		q
		0.886275 0 0.454902 rg 
		0.039 38.47 4.555 -4.559 re f
		13.93 38.47 4.555 -4.559 re f
		27.598 38.47 4.555 -4.559 re f
		41.266 38.47 4.555 -4.559 re f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		0 0 0 rg 74.262 29.381 m 74.262 43.002 l 77.188 43.002 l 77.188 37.822 l 81.527 
		37.822 l 81.527 43.002 l 84.453 43.002 l 84.453 29.381 l 81.527 29.381 l
		81.527 35.326 l 77.188 35.326 l 77.188 29.381 l h
		74.262 29.381 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		95.414 29.381 m 95.414 40.506 l 92.109 40.506 l 92.109 43.002 l 101.66 
		43.002 l 101.66 40.506 l 98.336 40.506 l 98.336 29.381 l h
		95.414 29.381 m f
		103.098 29.381 m 103.098 43.002 l 106.023 43.002 l 106.023 31.912 l 111.371
		31.912 l 111.371 29.381 l h
		103.098 29.381 m f
		0.886275 0 0.454902 rg 68.59 31.646 m 72.965 36.201 l 68.59 40.732 l h
		68.59 31.646 m f
		0.059 10.076 m 0.059 14.912 l 0.652 14.912 l 0.652 12.877 l 2.719 12.877
		l 2.719 14.912 l 3.309 14.912 l 3.309 10.076 l 2.719 10.076 l 2.719 12.365
		l 0.652 12.365 l 0.652 10.076 l h
		0.059 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		27.52 14.912 0.543 -4.836 re f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		43.719 10.076 m 43.719 14.396 l 42.371 14.396 l 42.371 14.912 l 45.652 
		14.912 l 45.652 14.396 l 44.312 14.396 l 44.312 10.076 l h
		43.719 10.076 m f
		q
		Q
		49.199 14.912 0.543 -4.836 re f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		54.129 10.076 m 54.129 14.912 l 54.672 14.912 l 54.672 12.072 l 55.957 
		13.412 l 56.648 13.412 l 55.434 12.174 l 56.727 10.076 l 56.086 10.076 l
		55.043 11.771 l 54.672 11.392 l 54.672 10.076 l h
		54.129 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		77.93 14.174 m 78.473 14.174 l 78.473 14.912 l 77.93 14.912 l h
		77.93 10.076 m 78.473 10.076 l 78.473 13.412 l 77.93 13.412 l h
		77.93 10.076 m f
		79.496 10.076 m 79.496 14.912 l 80.039 14.912 l 80.039 12.072 l 81.324 
		13.412 l 82.016 13.412 l 80.801 12.174 l 82.094 10.076 l 81.457 10.076 l
		80.41 11.771 l 80.039 11.392 l 80.039 10.076 l h
		79.496 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		87.855 14.174 m 88.398 14.174 l 88.398 14.912 l 87.855 14.912 l h
		87.855 10.076 m 88.398 10.076 l 88.398 13.412 l 87.855 13.412 l h
		87.855 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		97.816 10.076 m 97.816 14.912 l 98.406 14.912 l 98.406 10.588 l 100.512
		10.588 l 100.512 10.076 l h
		97.816 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		104.586 14.174 m 105.129 14.174 l 105.129 14.912 l 104.586 14.912 l h
		104.586 10.076 m 105.129 10.076 l 105.129 13.412 l 104.586 13.412 l h
		104.586 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		109.492 10.076 m 109.492 10.474 l 111.27 12.963 l 109.609 12.963 l 109.609
		13.412 l 111.941 13.412 l 111.941 13.052 l 110.148 10.525 l 112.008 10.525
		l 112.008 10.076 l h
		109.492 10.076 m f
		112.664 14.174 m 113.207 14.174 l 113.207 14.912 l 112.664 14.912 l h
		112.664 10.076 m 113.207 10.076 l 113.207 13.412 l 112.664 13.412 l h
		112.664 10.076 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		7.75 5.357 m 8.293 5.357 l 8.293 6.095 l 7.75 6.095 l h
		7.75 1.256 m 8.293 1.256 l 8.293 4.595 l 7.75 4.595 l h
		7.75 1.256 m f
		9.969 1.26 m 8.883 4.595 l 9.469 4.595 l 10.27 1.908 l 11.051 4.595 l 11.602
		4.595 l 10.539 1.26 l h
		9.969 1.26 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		20.559 5.357 m 21.102 5.357 l 21.102 6.095 l 20.559 6.095 l h
		20.559 1.256 m 21.102 1.256 l 21.102 4.595 l 20.559 4.595 l h
		20.559 1.256 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		36.211 6.095 m 36.867 6.095 l 38.441 1.26 l 37.797 1.26 l 37.344 2.744 
		l 35.703 2.744 l 35.246 1.26 l 34.633 1.26 l h
		35.855 3.244 m 37.191 3.244 l 36.531 5.435 l h
		35.855 3.244 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		46.34 6.095 0.543 -4.84 re f
		47.926 5.357 m 48.469 5.357 l 48.469 6.095 l 47.926 6.095 l h
		47.926 1.256 m 48.469 1.256 l 48.469 4.595 l 47.926 4.595 l h
		47.926 1.256 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		64.918 5.357 m 65.461 5.357 l 65.461 6.095 l 64.918 6.095 l h
		64.918 1.256 m 65.461 1.256 l 65.461 4.595 l 64.918 4.595 l h
		64.918 1.256 m f
		q
		1 0 0 1 0 -0.1819 cm
		Q
		Q				
		q
		0.886275 0 0.454902 rg 
		18.262 49 m 0.262 49 l 0.039 41.062 l 1.23 40.855 l 1.453 43.195 2.07 44.93
		3.074 46.062 c 4.133 47.246 5.59 47.867 7.461 47.922 c 7.461 31.312 l 7.461
		29.863 7.262 28.922 6.836 28.488 c 6.477 28.117 5.867 27.891 5.012 27.805
		c 4.758 27.781 4.324 27.773 3.711 27.773 c 3.711 26.504 l 14.816 26.504
		l 14.816 27.773 l 14.203 27.773 13.77 27.781 13.512 27.805 c 12.656 27.891
		12.047 28.117 11.688 28.488 c 11.266 28.922 11.059 29.863 11.059 31.312
		c 11.059 47.922 l 12.934 47.867 14.391 47.246 15.453 46.062 c 16.457 44.93
		17.07 43.195 17.293 40.855 c 18.488 41.062 l h
		18.262 49 m f
		Q			
		q
		0 0 0 rg 
		87.055 29.574 m 87.055 37.125 l 85.852 37.125 l 85.852 38.957 l 87.055 
		38.957 l 87.055 39.793 l 87.055 40.496 87.094 41.027 87.176 41.387 c 87.484
		42.789 88.512 43.488 90.254 43.488 c 90.332 43.488 90.73 43.465 91.445 
		43.418 c 91.445 41.387 l 91.168 41.426 90.926 41.445 90.719 41.445 c 90.297
		41.445 90.031 41.293 89.934 40.988 c 89.879 40.809 89.855 40.492 89.855
		40.031 c 89.855 38.957 l 91.34 38.957 l 91.34 37.125 l 89.855 37.125 l 
		89.855 29.574 l h
		87.055 29.574 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		5.617 13.695 m 6.047 13.695 6.391 13.535 6.652 13.211 c 6.906 12.898 7.031
		12.473 7.031 11.93 c 7.031 11.328 6.883 10.863 6.582 10.543 c 6.34 10.285
		6.016 10.152 5.609 10.152 c 5.137 10.152 4.773 10.32 4.52 10.656 c 4.273
		10.988 4.148 11.41 4.148 11.926 c 4.148 12.422 4.262 12.828 4.48 13.141
		c 4.746 13.512 5.125 13.695 5.617 13.695 c 5.582 13.262 m 5.328 13.262 
		5.121 13.152 4.969 12.934 c 4.789 12.684 4.699 12.348 4.699 11.93 c 4.699
		11.504 4.785 11.168 4.961 10.918 c 5.117 10.699 5.332 10.59 5.605 10.59
		c 5.852 10.59 6.047 10.684 6.191 10.871 c 6.387 11.125 6.484 11.477 6.484
		11.926 c 6.484 12.352 6.398 12.688 6.227 12.926 c 6.07 13.148 5.855 13.262
		5.582 13.262 c f
		9.816 11.445 m 10.359 11.445 l 10.355 11.188 10.277 10.941 10.125 10.715
		c 9.883 10.34 9.531 10.152 9.074 10.152 c 8.609 10.152 8.25 10.324 8 10.672
		c 7.762 11 7.641 11.418 7.641 11.926 c 7.641 12.418 7.754 12.824 7.98 13.148
		c 8.234 13.512 8.594 13.695 9.059 13.695 c 9.473 13.695 9.801 13.547 10.047
		13.254 c 10.199 13.074 10.297 12.836 10.348 12.539 c 9.789 12.539 l 9.758
		12.719 9.703 12.863 9.625 12.973 c 9.488 13.164 9.301 13.262 9.066 13.262
		c 8.801 13.262 8.59 13.145 8.438 12.906 c 8.27 12.652 8.188 12.328 8.188
		11.93 c 8.188 11.523 8.266 11.195 8.426 10.945 c 8.578 10.707 8.797 10.59
		9.074 10.59 c 9.34 10.59 9.539 10.719 9.68 10.98 c 9.75 11.105 9.793 11.258
		9.816 11.445 c f
		11.047 10.258 m 11.047 15.094 l 11.59 15.094 l 11.59 13.191 l 11.816 13.527
		12.125 13.695 12.527 13.695 c 12.93 13.695 13.215 13.551 13.387 13.262 
		c 13.484 13.094 13.535 12.812 13.535 12.426 c 13.535 10.258 l 12.992 10.258
		l 12.992 12.359 l 12.992 12.656 12.965 12.859 12.906 12.969 c 12.809 13.164
		12.637 13.262 12.391 13.262 c 12.059 13.262 11.824 13.094 11.688 12.762
		c 11.621 12.598 11.59 12.289 11.59 11.832 c 11.59 10.258 l h
		11.047 10.258 m f
		14.242 11.199 m 14.801 11.199 l 14.812 10.801 15.031 10.605 15.453 10.605
		c 15.656 10.605 15.809 10.656 15.91 10.754 c 15.992 10.84 16.035 10.953
		16.035 11.094 c 16.035 11.277 15.941 11.434 15.746 11.551 c 15.672 11.594
		15.496 11.672 15.219 11.781 c 14.918 11.898 14.707 12.023 14.582 12.16 
		c 14.426 12.328 14.348 12.535 14.348 12.777 c 14.348 13.062 14.449 13.293
		14.652 13.465 c 14.832 13.621 15.074 13.695 15.379 13.695 c 15.809 13.695
		16.117 13.551 16.301 13.258 c 16.391 13.117 16.445 12.941 16.465 12.734
		c 15.926 12.734 l 15.918 12.879 15.875 12.996 15.801 13.086 c 15.699 13.207
		15.555 13.27 15.371 13.27 c 15.199 13.27 15.07 13.219 14.98 13.117 c 14.91
		13.039 14.875 12.938 14.875 12.812 c 14.875 12.672 14.922 12.562 15.016
		12.48 c 15.109 12.402 15.289 12.309 15.562 12.207 c 15.914 12.078 16.164
		11.953 16.301 11.836 c 16.516 11.656 16.621 11.426 16.621 11.148 c 16.621
		10.848 16.516 10.602 16.309 10.414 c 16.117 10.242 15.844 10.152 15.496
		10.152 c 14.984 10.152 14.625 10.316 14.422 10.645 c 14.316 10.809 14.254
		10.996 14.242 11.199 c f
		19.328 11.445 m 19.875 11.445 l 19.867 11.188 19.789 10.941 19.641 10.715
		c 19.395 10.34 19.047 10.152 18.586 10.152 c 18.121 10.152 17.766 10.324
		17.516 10.672 c 17.273 11 17.156 11.418 17.156 11.926 c 17.156 12.418 17.27
		12.824 17.492 13.148 c 17.746 13.512 18.109 13.695 18.574 13.695 c 18.988
		13.695 19.316 13.547 19.562 13.254 c 19.711 13.074 19.809 12.836 19.859
		12.539 c 19.305 12.539 l 19.27 12.719 19.215 12.863 19.141 12.973 c 19 
		13.164 18.812 13.262 18.578 13.262 c 18.312 13.262 18.102 13.145 17.949 
		12.906 c 17.785 12.652 17.703 12.328 17.703 11.93 c 17.703 11.523 17.781
		11.195 17.938 10.945 c 18.094 10.707 18.309 10.59 18.586 10.59 c 18.852
		10.59 19.055 10.719 19.191 10.98 c 19.262 11.105 19.309 11.258 19.328 11.445
		c f
		20.562 10.258 m 20.562 15.094 l 21.102 15.094 l 21.102 13.191 l 21.328 
		13.527 21.641 13.695 22.043 13.695 c 22.445 13.695 22.73 13.551 22.898 13.262
		c 23 13.094 23.047 12.812 23.047 12.426 c 23.047 10.258 l 22.508 10.258
		l 22.508 12.359 l 22.508 12.656 22.477 12.859 22.422 12.969 c 22.32 13.164
		22.148 13.262 21.902 13.262 c 21.574 13.262 21.34 13.094 21.203 12.762 
		c 21.137 12.598 21.102 12.289 21.102 11.832 c 21.102 10.258 l h
		20.562 10.258 m f
		26.492 10.258 m 25.984 10.258 l 25.984 10.707 l 25.738 10.336 25.414 10.152
		25.008 10.152 c 24.605 10.152 24.32 10.301 24.156 10.59 c 24.078 10.723
		24.031 10.875 24.02 11.039 c 24.008 11.156 24.004 11.289 24.004 11.438 
		c 24.004 13.594 l 24.547 13.594 l 24.547 11.629 l 24.547 11.324 24.566 11.109
		24.602 10.98 c 24.633 10.859 24.699 10.766 24.797 10.695 c 24.891 10.625
		25.008 10.59 25.145 10.59 c 25.391 10.59 25.586 10.688 25.73 10.883 c 25.828
		11.012 25.895 11.184 25.922 11.398 c 25.941 11.527 25.949 11.723 25.949
		11.977 c 25.949 13.594 l 26.492 13.594 l h
		26.492 10.258 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		31.637 11.785 m 29.438 11.785 l 29.441 11.559 29.473 11.363 29.531 11.195
		c 29.672 10.793 29.934 10.59 30.309 10.59 c 30.605 10.59 30.816 10.715 
		30.945 10.969 c 30.992 11.059 31.035 11.18 31.078 11.324 c 31.602 11.324
		l 31.551 11.051 31.461 10.828 31.328 10.648 c 31.086 10.32 30.75 10.152
		30.316 10.152 c 29.832 10.152 29.465 10.336 29.215 10.707 c 28.996 11.031
		28.887 11.441 28.887 11.934 c 28.887 12.449 29.016 12.871 29.266 13.203
		c 29.516 13.531 29.855 13.695 30.277 13.695 c 30.625 13.695 30.918 13.59
		31.148 13.371 c 31.398 13.133 31.551 12.777 31.605 12.309 c 31.621 12.168
		31.633 11.992 31.637 11.785 c 31.082 12.219 m 31.066 12.457 31.023 12.656
		30.953 12.809 c 30.816 13.113 30.594 13.262 30.285 13.262 c 29.992 13.262
		29.77 13.125 29.625 12.852 c 29.535 12.684 29.477 12.473 29.445 12.219 
		c h
		31.082 12.219 m f
		33.969 10.258 m 33.969 13.145 l 33.484 13.145 l 33.484 13.594 l 33.969 
		13.594 l 33.969 13.918 l 33.969 14.367 34.008 14.664 34.094 14.816 c 34.234
		15.074 34.465 15.203 34.781 15.203 c 34.887 15.203 35.004 15.188 35.137
		15.152 c 35.137 14.66 l 35.031 14.703 34.945 14.723 34.875 14.723 c 34.707
		14.723 34.602 14.652 34.555 14.512 c 34.523 14.426 34.512 14.285 34.512
		14.09 c 34.512 13.594 l 35.059 13.594 l 35.059 13.145 l 34.512 13.145 l
		34.512 10.258 l h
		33.969 10.258 m f
		38.137 10.258 m 37.633 10.258 l 37.633 10.707 l 37.387 10.336 37.059 10.152
		36.652 10.152 c 36.254 10.152 35.969 10.301 35.805 10.59 c 35.727 10.723
		35.68 10.875 35.664 11.039 c 35.656 11.156 35.652 11.289 35.652 11.438 
		c 35.652 13.594 l 36.195 13.594 l 36.195 11.629 l 36.195 11.324 36.211 11.109
		36.246 10.98 c 36.281 10.859 36.344 10.766 36.441 10.695 c 36.539 10.625
		36.656 10.59 36.793 10.59 c 37.035 10.59 37.23 10.688 37.375 10.883 c 37.477
		11.012 37.539 11.184 37.57 11.398 c 37.586 11.527 37.598 11.723 37.598 
		11.977 c 37.598 13.594 l 38.137 13.594 l h
		36.66 14.176 m 36.152 14.176 l 36.152 14.852 l 36.66 14.852 l h
		37.668 14.176 m 37.16 14.176 l 37.16 14.852 l 37.668 14.852 l h
		37.668 14.176 m f
		39.152 10.258 m 39.152 13.594 l 39.66 13.594 l 39.66 12.969 l 39.875 13.473
		40.238 13.715 40.746 13.695 c 40.746 13.09 l 40.66 13.102 40.602 13.105
		40.57 13.105 c 40.316 13.105 40.113 13 39.957 12.789 c 39.824 12.617 39.746
		12.379 39.715 12.082 c 39.699 11.922 39.695 11.711 39.695 11.449 c 39.695
		10.258 l h
		39.152 10.258 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		48.375 11.785 m 46.176 11.785 l 46.18 11.559 46.211 11.363 46.27 11.195
		c 46.41 10.793 46.672 10.59 47.047 10.59 c 47.34 10.59 47.555 10.715 47.684
		10.969 c 47.73 11.059 47.773 11.18 47.816 11.324 c 48.34 11.324 l 48.289
		11.051 48.199 10.828 48.066 10.648 c 47.824 10.32 47.488 10.152 47.051 
		10.152 c 46.57 10.152 46.203 10.336 45.953 10.707 c 45.734 11.031 45.625
		11.441 45.625 11.934 c 45.625 12.449 45.75 12.871 46.004 13.203 c 46.254
		13.531 46.59 13.695 47.012 13.695 c 47.363 13.695 47.656 13.59 47.887 13.371
		c 48.137 13.133 48.289 12.777 48.344 12.309 c 48.359 12.168 48.371 11.992
		48.375 11.785 c 47.82 12.219 m 47.805 12.457 47.762 12.656 47.691 12.809
		c 47.555 13.113 47.332 13.262 47.023 13.262 c 46.73 13.262 46.508 13.125
		46.363 12.852 c 46.273 12.684 46.211 12.473 46.18 12.219 c h
		47.82 12.219 m f
		Q		
		q
		0.886275 0 0.454902 rg 
		53.316 11.785 m 51.117 11.785 l 51.121 11.559 51.152 11.363 51.211 11.195
		c 51.355 10.793 51.613 10.59 51.988 10.59 c 52.285 10.59 52.496 10.715 
		52.625 10.969 c 52.672 11.059 52.719 11.18 52.758 11.324 c 53.281 11.324
		l 53.23 11.051 53.141 10.828 53.008 10.648 c 52.77 10.32 52.43 10.152 51.996
		10.152 c 51.512 10.152 51.145 10.336 50.898 10.707 c 50.676 11.031 50.566
		11.441 50.566 11.934 c 50.566 12.449 50.695 12.871 50.949 13.203 c 51.199
		13.531 51.535 13.695 51.957 13.695 c 52.305 13.695 52.598 13.59 52.828 
		13.371 c 53.078 13.133 53.23 12.777 53.285 12.309 c 53.301 12.168 53.312
		11.992 53.316 11.785 c 52.766 12.219 m 52.75 12.457 52.703 12.656 52.633
		12.809 c 52.496 13.113 52.273 13.262 51.965 13.262 c 51.672 13.262 51.453
		13.125 51.305 12.852 c 51.215 12.684 51.156 12.473 51.125 12.219 c h
		52.766 12.219 m f
		Q		
		q
		0.886275 0 0.454902 rg 
		58.438 13.695 m 58.867 13.695 59.215 13.535 59.477 13.211 c 59.727 12.898
		59.855 12.473 59.855 11.93 c 59.855 11.328 59.703 10.863 59.402 10.543 
		c 59.16 10.285 58.836 10.152 58.43 10.152 c 57.957 10.152 57.594 10.32 57.344
		10.656 c 57.094 10.988 56.969 11.41 56.969 11.926 c 56.969 12.422 57.082
		12.828 57.305 13.141 c 57.566 13.512 57.945 13.695 58.438 13.695 c 58.406
		13.262 m 58.148 13.262 57.945 13.152 57.789 12.934 c 57.609 12.684 57.52
		12.348 57.52 11.93 c 57.52 11.504 57.605 11.168 57.781 10.918 c 57.938 
		10.699 58.152 10.59 58.426 10.59 c 58.672 10.59 58.867 10.684 59.012 10.871
		c 59.207 11.125 59.305 11.477 59.305 11.926 c 59.305 12.352 59.219 12.688
		59.047 12.926 c 58.891 13.148 58.676 13.262 58.406 13.262 c f
		60.664 10.258 m 60.664 13.594 l 61.172 13.594 l 61.172 13.172 l 61.277 
		13.324 61.383 13.438 61.48 13.512 c 61.648 13.637 61.844 13.695 62.066 13.695
		c 62.48 13.695 62.766 13.512 62.914 13.145 c 63.152 13.512 63.477 13.695
		63.883 13.695 c 64.105 13.695 64.297 13.637 64.465 13.52 c 64.648 13.387
		64.762 13.191 64.805 12.934 c 64.82 12.844 64.828 12.719 64.828 12.562 
		c 64.828 10.258 l 64.285 10.258 l 64.285 12.359 l 64.285 12.633 64.27 12.82
		64.238 12.922 c 64.16 13.148 63.992 13.262 63.734 13.262 c 63.414 13.262
		63.199 13.09 63.082 12.75 c 63.039 12.629 63.02 12.387 63.02 12.027 c 63.02
		10.258 l 62.477 10.258 l 62.477 12.402 l 62.477 12.723 62.441 12.938 62.371
		13.055 c 62.281 13.191 62.148 13.262 61.961 13.262 c 61.77 13.262 61.609
		13.188 61.473 13.043 c 61.34 12.906 61.258 12.715 61.23 12.469 c 61.215
		12.355 61.207 12.207 61.207 12.023 c 61.207 10.258 l h
		60.664 10.258 m f
		65.816 10.258 m 65.816 13.594 l 66.324 13.594 l 66.324 13.172 l 66.43 13.324
		66.535 13.438 66.633 13.512 c 66.801 13.637 66.996 13.695 67.219 13.695
		c 67.633 13.695 67.918 13.512 68.066 13.145 c 68.305 13.512 68.625 13.695
		69.035 13.695 c 69.258 13.695 69.449 13.637 69.617 13.52 c 69.801 13.387
		69.914 13.191 69.957 12.934 c 69.973 12.844 69.98 12.719 69.98 12.562 c
		69.98 10.258 l 69.438 10.258 l 69.438 12.359 l 69.438 12.633 69.422 12.82
		69.391 12.922 c 69.312 13.148 69.145 13.262 68.887 13.262 c 68.566 13.262
		68.348 13.09 68.234 12.75 c 68.191 12.629 68.172 12.387 68.172 12.027 c
		68.172 10.258 l 67.629 10.258 l 67.629 12.402 l 67.629 12.723 67.594 12.938
		67.523 13.055 c 67.434 13.191 67.297 13.262 67.113 13.262 c 66.922 13.262
		66.758 13.188 66.625 13.043 c 66.492 12.906 66.41 12.715 66.379 12.469 
		c 66.367 12.355 66.359 12.207 66.359 12.023 c 66.359 10.258 l h
		65.816 10.258 m f
		73.43 10.258 m 72.922 10.258 l 72.922 10.707 l 72.676 10.336 72.352 10.152
		71.941 10.152 c 71.543 10.152 71.258 10.301 71.094 10.59 c 71.016 10.723
		70.969 10.875 70.957 11.039 c 70.945 11.156 70.941 11.289 70.941 11.438
		c 70.941 13.594 l 71.484 13.594 l 71.484 11.629 l 71.484 11.324 71.5 11.109
		71.535 10.98 c 71.57 10.859 71.633 10.766 71.73 10.695 c 71.828 10.625 
		71.945 10.59 72.082 10.59 c 72.324 10.59 72.52 10.688 72.668 10.883 c 72.766
		11.012 72.828 11.184 72.859 11.398 c 72.875 11.527 72.887 11.723 72.887
		11.977 c 72.887 13.594 l 73.43 13.594 l h
		73.43 10.258 m f
		74.441 10.258 m 74.441 13.594 l 74.949 13.594 l 74.949 13.145 l 75.195 
		13.512 75.523 13.695 75.941 13.695 c 76.184 13.695 76.395 13.629 76.566 
		13.5 c 76.746 13.359 76.859 13.164 76.902 12.902 c 76.918 12.797 76.93 12.633
		76.93 12.414 c 76.93 10.258 l 76.387 10.258 l 76.387 12.223 l 76.387 12.523
		76.367 12.742 76.332 12.871 c 76.301 12.988 76.234 13.082 76.137 13.152
		c 76.043 13.227 75.926 13.262 75.789 13.262 c 75.543 13.262 75.348 13.164
		75.203 12.969 c 75.105 12.84 75.039 12.664 75.012 12.453 c 74.992 12.32
		74.984 12.129 74.984 11.875 c 74.984 10.258 l h
		74.441 10.258 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		85.273 10.711 m 85.273 10.293 l 85.168 10.227 85.051 10.191 84.93 10.191
		c 84.785 10.191 84.672 10.234 84.594 10.324 c 84.512 10.41 84.473 10.523
		84.473 10.672 c 84.473 10.766 l 84.203 10.359 83.863 10.152 83.453 10.152
		c 83.195 10.152 82.977 10.23 82.797 10.379 c 82.578 10.562 82.469 10.809
		82.469 11.121 c 82.469 11.465 82.602 11.734 82.863 11.93 c 83.059 12.074
		83.34 12.168 83.703 12.203 c 83.867 12.223 84.109 12.234 84.438 12.242 
		c 84.438 12.551 l 84.438 13.023 84.219 13.258 83.785 13.258 c 83.523 13.258
		83.34 13.168 83.227 12.988 c 83.164 12.891 83.129 12.75 83.113 12.566 c
		82.586 12.566 l 82.602 12.914 82.711 13.188 82.91 13.383 c 83.125 13.594
		83.426 13.695 83.816 13.695 c 84.246 13.695 84.562 13.566 84.762 13.305
		c 84.863 13.172 84.922 13 84.941 12.789 c 84.953 12.707 84.957 12.543 84.957
		12.293 c 84.957 11.031 l 84.961 10.859 84.969 10.754 84.98 10.727 c 85.004
		10.68 85.043 10.656 85.098 10.656 c 85.152 10.656 85.211 10.676 85.273 
		10.711 c 84.438 11.879 m 84.098 11.863 83.836 11.836 83.645 11.793 c 83.445
		11.75 83.297 11.676 83.195 11.57 c 83.074 11.449 83.016 11.301 83.016 11.133
		c 83.016 10.977 83.066 10.848 83.168 10.742 c 83.266 10.641 83.391 10.59
		83.543 10.59 c 83.734 10.59 83.902 10.656 84.059 10.789 c 84.203 10.914
		84.309 11.082 84.367 11.289 c 84.414 11.438 84.438 11.57 84.438 11.695 
		c h
		84.438 11.879 m f
		85.559 13.145 m 85.559 13.594 l 86.043 13.594 l 86.043 14.094 l 86.484 
		14.684 l 86.586 14.684 l 86.586 13.594 l 87.152 13.594 l 87.152 13.145 l
		86.586 13.145 l 86.586 11.168 l 86.586 10.957 86.598 10.828 86.621 10.777
		c 86.676 10.68 86.766 10.633 86.895 10.633 c 86.965 10.633 87.051 10.648
		87.152 10.68 c 87.152 10.23 l 87.012 10.199 86.891 10.184 86.781 10.184
		c 86.461 10.184 86.242 10.273 86.133 10.449 c 86.09 10.527 86.062 10.645
		86.051 10.797 c 86.047 10.898 86.043 11.043 86.043 11.234 c 86.043 13.145
		l h
		85.559 13.145 m f
		Q		
		q
		0.886275 0 0.454902 rg 
		90.691 13.695 m 91.121 13.695 91.465 13.535 91.727 13.211 c 91.98 12.898
		92.105 12.473 92.105 11.93 c 92.105 11.328 91.957 10.863 91.656 10.543 
		c 91.414 10.285 91.09 10.152 90.684 10.152 c 90.211 10.152 89.848 10.32 
		89.594 10.656 c 89.348 10.988 89.223 11.41 89.223 11.926 c 89.223 12.422
		89.336 12.828 89.555 13.141 c 89.82 13.512 90.199 13.695 90.691 13.695 
		c 90.66 13.262 m 90.402 13.262 90.199 13.152 90.043 12.934 c 89.863 12.684
		89.773 12.348 89.773 11.93 c 89.773 11.504 89.859 11.168 90.035 10.918 
		c 90.191 10.699 90.406 10.59 90.68 10.59 c 90.926 10.59 91.121 10.684 91.266
		10.871 c 91.461 11.125 91.559 11.477 91.559 11.926 c 91.559 12.352 91.473
		12.688 91.301 12.926 c 91.145 13.148 90.93 13.262 90.66 13.262 c f
		92.918 10.258 m 92.918 13.594 l 93.426 13.594 l 93.426 13.145 l 93.672 
		13.512 94.004 13.695 94.418 13.695 c 94.664 13.695 94.871 13.629 95.047 
		13.5 c 95.223 13.359 95.336 13.164 95.379 12.902 c 95.398 12.797 95.406 
		12.633 95.406 12.414 c 95.406 10.258 l 94.863 10.258 l 94.863 12.223 l 94.863
		12.523 94.848 12.742 94.812 12.871 c 94.777 12.988 94.715 13.082 94.617
		13.152 c 94.52 13.227 94.402 13.262 94.266 13.262 c 94.023 13.262 93.828
		13.164 93.68 12.969 c 93.582 12.84 93.52 12.664 93.488 12.453 c 93.473 
		12.32 93.461 12.129 93.461 11.875 c 93.461 10.258 l h
		92.918 10.258 m f
		Q		
		q
		0.886275 0 0.454902 rg 
		103.762 11.785 m 101.562 11.785 l 101.566 11.559 101.598 11.363 101.656
		11.195 c 101.797 10.793 102.059 10.59 102.434 10.59 c 102.727 10.59 102.941
		10.715 103.07 10.969 c 103.117 11.059 103.16 11.18 103.199 11.324 c 103.727
		11.324 l 103.676 11.051 103.586 10.828 103.453 10.648 c 103.211 10.32 102.875
		10.152 102.438 10.152 c 101.957 10.152 101.59 10.336 101.34 10.707 c 101.121
		11.031 101.012 11.441 101.012 11.934 c 101.012 12.449 101.137 12.871 101.391
		13.203 c 101.641 13.531 101.977 13.695 102.398 13.695 c 102.75 13.695 103.043
		13.59 103.273 13.371 c 103.523 13.133 103.676 12.777 103.73 12.309 c 103.746
		12.168 103.758 11.992 103.762 11.785 c 103.207 12.219 m 103.191 12.457 
		103.148 12.656 103.078 12.809 c 102.941 13.113 102.719 13.262 102.406 13.262
		c 102.113 13.262 101.895 13.125 101.75 12.852 c 101.66 12.684 101.598 12.473
		101.566 12.219 c h
		103.207 12.219 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		106.16 9 m 106.16 13.594 l 106.668 13.594 l 106.668 13.191 l 106.875 13.527
		107.191 13.695 107.609 13.695 c 108.016 13.695 108.34 13.543 108.586 13.238
		c 108.852 12.91 108.984 12.469 108.984 11.906 c 108.984 11.367 108.859 
		10.938 108.609 10.625 c 108.363 10.309 108.039 10.152 107.641 10.152 c 107.242
		10.152 106.93 10.316 106.703 10.641 c 106.703 9 l h
		107.551 13.262 m 107.387 13.262 107.23 13.203 107.086 13.082 c 106.82 12.867
		106.688 12.48 106.688 11.926 c 106.688 11.492 106.773 11.156 106.949 10.914
		c 107.105 10.699 107.312 10.59 107.566 10.59 c 107.832 10.59 108.039 10.703
		108.188 10.93 c 108.352 11.184 108.434 11.508 108.434 11.91 c 108.434 12.312
		108.352 12.645 108.191 12.898 c 108.035 13.141 107.824 13.262 107.551 13.262
		c f
		Q			
		q
		0.886275 0 0.454902 rg 
		114.133 9.988 m 114.68 9.988 l 114.715 9.832 114.777 9.711 114.871 9.625
		c 115.012 9.496 115.195 9.434 115.418 9.434 c 115.961 9.434 116.234 9.801
		116.234 10.527 c 116.234 10.75 l 116.055 10.391 115.758 10.211 115.34 10.211
		c 114.941 10.211 114.629 10.363 114.395 10.668 c 114.152 10.984 114.031
		11.398 114.031 11.91 c 114.031 12.453 114.16 12.891 114.418 13.223 c 114.551
		13.391 114.711 13.52 114.906 13.605 c 115.055 13.664 115.207 13.695 115.367
		13.695 c 115.598 13.695 115.801 13.637 115.973 13.512 c 116.074 13.438 
		116.176 13.328 116.27 13.18 c 116.27 13.594 l 116.773 13.594 l 116.773 10.727
		l 116.773 10.238 116.699 9.871 116.559 9.621 c 116.43 9.402 116.246 9.238
		116.012 9.125 c 115.828 9.039 115.625 8.996 115.402 8.996 c 114.93 8.996
		114.574 9.148 114.344 9.453 c 114.227 9.609 114.156 9.789 114.133 9.988
		c 115.398 13.262 m 115.129 13.262 114.918 13.125 114.77 12.852 c 114.645
		12.617 114.582 12.312 114.582 11.938 c 114.582 11.469 114.68 11.121 114.875
		10.898 c 115.023 10.73 115.203 10.645 115.41 10.645 c 115.582 10.645 115.727
		10.699 115.844 10.805 c 116.113 11.051 116.246 11.449 116.246 12.008 c 
		116.246 12.445 116.152 12.777 115.965 13.004 c 115.816 13.176 115.629 13.262
		115.398 13.262 c f
		0 6.277 m 0.586 6.277 l 0.586 3.543 l 0.586 3.211 0.594 2.973 0.613 2.832
		c 0.664 2.461 0.789 2.191 0.988 2.035 c 1.16 1.898 1.391 1.828 1.68 1.828
		c 2.145 1.828 2.449 2.031 2.594 2.434 c 2.672 2.641 2.711 3.012 2.711 3.543
		c 2.711 6.277 l 3.301 6.277 l 3.301 3.551 l 3.301 3.066 3.273 2.715 3.215
		2.5 c 3 1.715 2.492 1.324 1.688 1.324 c 1.242 1.324 0.895 1.422 0.641 1.617
		c 0.363 1.832 0.18 2.137 0.082 2.531 c 0.027 2.754 0 3.098 0 3.562 c h
		0 6.277 m f
		4.262 1.441 m 4.262 4.777 l 4.77 4.777 l 4.77 4.328 l 5.016 4.695 5.344
		4.879 5.762 4.879 c 6.008 4.879 6.215 4.812 6.387 4.684 c 6.566 4.543 6.68
		4.348 6.723 4.086 c 6.742 3.98 6.75 3.816 6.75 3.598 c 6.75 1.441 l 6.207
		1.441 l 6.207 3.406 l 6.207 3.707 6.188 3.926 6.156 4.055 c 6.121 4.172
		6.055 4.266 5.961 4.336 c 5.863 4.41 5.746 4.445 5.609 4.445 c 5.367 4.445
		5.172 4.348 5.023 4.152 c 4.926 4.023 4.863 3.848 4.832 3.637 c 4.812 3.504
		4.805 3.312 4.805 3.059 c 4.805 1.441 l h
		4.262 1.441 m f
		Q		
		q
		0.886275 0 0.454902 rg 
		14.652 2.965 m 12.449 2.965 l 12.453 2.742 12.488 2.547 12.547 2.379 c 
		12.688 1.977 12.945 1.773 13.32 1.773 c 13.617 1.773 13.828 1.898 13.961
		2.152 c 14.008 2.242 14.051 2.363 14.09 2.504 c 14.617 2.504 l 14.566 2.234
		14.477 2.008 14.344 1.832 c 14.102 1.5 13.766 1.336 13.328 1.336 c 12.844
		1.336 12.48 1.52 12.23 1.891 c 12.012 2.215 11.902 2.625 11.902 3.117 c
		11.902 3.633 12.027 4.055 12.281 4.387 c 12.531 4.715 12.867 4.879 13.289
		4.879 c 13.641 4.879 13.93 4.773 14.16 4.555 c 14.41 4.316 14.566 3.961
		14.617 3.492 c 14.637 3.352 14.645 3.176 14.652 2.965 c 14.098 3.402 m 
		14.082 3.641 14.039 3.84 13.969 3.996 c 13.828 4.293 13.605 4.445 13.297
		4.445 c 13.004 4.445 12.785 4.309 12.641 4.035 c 12.551 3.867 12.488 3.656
		12.457 3.402 c h
		14.098 3.402 m f
		15.461 1.441 m 15.461 4.777 l 15.969 4.777 l 15.969 4.152 l 16.188 4.656
		16.551 4.898 17.055 4.879 c 17.055 4.273 l 16.973 4.285 16.914 4.289 16.879
		4.289 c 16.629 4.289 16.422 4.184 16.266 3.973 c 16.137 3.797 16.055 3.562
		16.023 3.266 c 16.012 3.105 16.004 2.895 16.004 2.633 c 16.004 1.441 l 
		h
		15.461 1.441 m f
		17.43 2.383 m 17.984 2.383 l 18 1.984 18.215 1.789 18.637 1.789 c 18.84
		1.789 18.992 1.84 19.094 1.938 c 19.18 2.023 19.223 2.137 19.223 2.277 
		c 19.223 2.461 19.125 2.613 18.93 2.734 c 18.859 2.777 18.684 2.855 18.402
		2.965 c 18.102 3.082 17.891 3.207 17.766 3.344 c 17.609 3.512 17.531 3.719
		17.531 3.961 c 17.531 4.246 17.633 4.477 17.836 4.648 c 18.02 4.805 18.258
		4.879 18.562 4.879 c 18.996 4.879 19.301 4.734 19.488 4.441 c 19.578 4.301
		19.633 4.125 19.652 3.918 c 19.113 3.918 l 19.102 4.062 19.062 4.18 18.988
		4.27 c 18.887 4.391 18.742 4.449 18.555 4.449 c 18.387 4.449 18.254 4.402
		18.164 4.301 c 18.094 4.223 18.059 4.121 18.059 3.996 c 18.059 3.855 18.105
		3.746 18.199 3.664 c 18.293 3.586 18.477 3.492 18.746 3.391 c 19.102 3.262
		19.348 3.137 19.488 3.02 c 19.699 2.84 19.805 2.609 19.805 2.332 c 19.805
		2.031 19.703 1.785 19.496 1.598 c 19.301 1.426 19.031 1.336 18.684 1.336
		c 18.168 1.336 17.809 1.5 17.605 1.824 c 17.5 1.992 17.441 2.18 17.43 2.383
		c f
		Q			
		q
		0.886275 0 0.454902 rg 
		21.703 4.328 m 21.703 4.777 l 22.184 4.777 l 22.184 5.277 l 22.625 5.867
		l 22.727 5.867 l 22.727 4.777 l 23.297 4.777 l 23.297 4.328 l 22.727 4.328
		l 22.727 2.352 l 22.727 2.141 22.738 2.012 22.766 1.961 c 22.816 1.863 
		22.906 1.816 23.039 1.816 c 23.105 1.816 23.191 1.832 23.297 1.863 c 23.297
		1.414 l 23.156 1.383 23.031 1.367 22.922 1.367 c 22.602 1.367 22.383 1.457
		22.277 1.633 c 22.23 1.711 22.203 1.828 22.195 1.98 c 22.188 2.082 22.184
		2.227 22.184 2.418 c 22.184 4.328 l h
		21.703 4.328 m f
		23.832 0.234 m 23.832 0.703 l 23.867 0.691 23.891 0.684 23.898 0.68 c 23.984
		0.645 24.059 0.629 24.129 0.629 c 24.254 0.629 24.344 0.672 24.398 0.754
		c 24.461 0.848 24.562 1.105 24.703 1.52 c 23.547 4.777 l 24.141 4.777 l
		24.98 2.188 l 25.773 4.777 l 26.336 4.777 l 25.258 1.602 l 25.07 1.047 
		24.934 0.699 24.852 0.555 c 24.707 0.305 24.484 0.184 24.18 0.184 c 24.082
		0.184 23.965 0.199 23.832 0.234 c f
		29.574 4.879 m 30.004 4.879 30.352 4.719 30.613 4.395 c 30.867 4.082 30.992
		3.656 30.992 3.113 c 30.992 2.512 30.84 2.047 30.543 1.727 c 30.297 1.469
		29.973 1.336 29.566 1.336 c 29.094 1.336 28.734 1.504 28.48 1.84 c 28.23
		2.172 28.109 2.594 28.109 3.109 c 28.109 3.605 28.219 4.012 28.441 4.324
		c 28.707 4.695 29.082 4.879 29.574 4.879 c 29.543 4.445 m 29.289 4.445 
		29.082 4.336 28.926 4.117 c 28.746 3.867 28.656 3.531 28.656 3.113 c 28.656
		2.688 28.746 2.352 28.918 2.102 c 29.074 1.883 29.289 1.773 29.562 1.773
		c 29.809 1.773 30.004 1.867 30.148 2.055 c 30.344 2.309 30.441 2.66 30.441
		3.109 c 30.441 3.535 30.355 3.871 30.184 4.109 c 30.027 4.332 29.816 4.445
		29.543 4.445 c f
		31.93 1.441 m 31.93 4.328 l 31.449 4.328 l 31.449 4.777 l 31.93 4.777 l
		31.93 5.102 l 31.93 5.547 31.973 5.848 32.055 6 c 32.195 6.258 32.426 6.387
		32.746 6.387 c 32.852 6.387 32.969 6.371 33.102 6.336 c 33.102 5.844 l 
		32.996 5.887 32.91 5.906 32.836 5.906 c 32.668 5.906 32.562 5.836 32.516
		5.695 c 32.488 5.609 32.473 5.469 32.473 5.273 c 32.473 4.777 l 33.023 
		4.777 l 33.023 4.328 l 32.473 4.328 l 32.473 1.441 l h
		31.93 1.441 m f
		Q			
		q
		0.886275 0 0.454902 rg 
		39.051 0.184 m 39.051 4.777 l 39.559 4.777 l 39.559 4.375 l 39.77 4.711
		40.082 4.879 40.5 4.879 c 40.906 4.879 41.234 4.727 41.48 4.422 c 41.746
		4.094 41.875 3.652 41.875 3.09 c 41.875 2.551 41.75 2.121 41.5 1.809 c 
		41.254 1.492 40.934 1.336 40.535 1.336 c 40.133 1.336 39.82 1.5 39.594 1.824
		c 39.594 0.184 l h
		40.445 4.445 m 40.277 4.445 40.121 4.387 39.977 4.266 c 39.711 4.051 39.582
		3.664 39.582 3.109 c 39.582 2.676 39.668 2.34 39.844 2.098 c 40 1.883 40.203
		1.773 40.461 1.773 c 40.727 1.773 40.934 1.887 41.078 2.113 c 41.246 2.367
		41.328 2.691 41.328 3.094 c 41.328 3.496 41.246 3.828 41.082 4.082 c 40.93
		4.324 40.715 4.445 40.445 4.445 c f
		42.691 0.184 m 42.691 4.777 l 43.199 4.777 l 43.199 4.375 l 43.41 4.711
		43.723 4.879 44.141 4.879 c 44.547 4.879 44.871 4.727 45.117 4.422 c 45.383
		4.094 45.516 3.652 45.516 3.09 c 45.516 2.551 45.391 2.121 45.141 1.809
		c 44.895 1.492 44.57 1.336 44.172 1.336 c 43.773 1.336 43.461 1.5 43.234
		1.824 c 43.234 0.184 l h
		44.082 4.445 m 43.918 4.445 43.762 4.387 43.617 4.266 c 43.352 4.051 43.219
		3.664 43.219 3.109 c 43.219 2.676 43.305 2.34 43.48 2.098 c 43.637 1.883
		43.844 1.773 44.098 1.773 c 44.367 1.773 44.57 1.887 44.719 2.113 c 44.883
		2.367 44.965 2.691 44.965 3.094 c 44.965 3.496 44.883 3.828 44.723 4.082
		c 44.57 4.324 44.355 4.445 44.082 4.445 c f
		Q			
		q
		0.886275 0 0.454902 rg 
		52.043 2.965 m 49.844 2.965 l 49.848 2.742 49.879 2.547 49.938 2.379 c 
		50.078 1.977 50.336 1.773 50.711 1.773 c 51.008 1.773 51.223 1.898 51.352
		2.152 c 51.398 2.242 51.441 2.363 51.48 2.504 c 52.008 2.504 l 51.957 2.234
		51.867 2.008 51.734 1.832 c 51.492 1.5 51.156 1.336 50.719 1.336 c 50.234
		1.336 49.871 1.52 49.621 1.891 c 49.402 2.215 49.293 2.625 49.293 3.117
		c 49.293 3.633 49.418 4.055 49.672 4.387 c 49.922 4.715 50.258 4.879 50.68
		4.879 c 51.031 4.879 51.32 4.773 51.555 4.555 c 51.805 4.316 51.957 3.961
		52.012 3.492 c 52.027 3.352 52.035 3.176 52.043 2.965 c 51.488 3.402 m 
		51.473 3.641 51.43 3.84 51.359 3.996 c 51.223 4.293 50.996 4.445 50.688 
		4.445 c 50.395 4.445 50.176 4.309 50.031 4.035 c 49.941 3.867 49.879 3.656
		49.848 3.402 c h
		51.488 3.402 m f
		55.473 1.441 m 54.969 1.441 l 54.969 1.844 l 54.75 1.504 54.438 1.336 54.023
		1.336 c 53.617 1.336 53.289 1.488 53.043 1.793 c 52.781 2.121 52.648 2.566
		52.648 3.125 c 52.648 3.668 52.773 4.094 53.023 4.41 c 53.27 4.723 53.59
		4.879 53.992 4.879 c 54.391 4.879 54.703 4.715 54.93 4.391 c 54.93 6.277
		l 55.473 6.277 l h
		54.051 4.445 m 53.887 4.445 53.734 4.387 53.594 4.27 c 53.457 4.16 53.359
		4 53.289 3.781 c 53.227 3.582 53.195 3.359 53.195 3.117 c 53.195 2.719 
		53.273 2.395 53.438 2.133 c 53.59 1.895 53.797 1.773 54.062 1.773 c 54.238
		1.773 54.398 1.832 54.543 1.949 c 54.812 2.168 54.945 2.551 54.945 3.102
		c 54.945 3.539 54.855 3.879 54.68 4.121 c 54.523 4.336 54.312 4.445 54.051
		4.445 c f
		57.664 2.941 m 58.25 2.941 l 58.27 2.664 58.324 2.445 58.422 2.289 c 58.609
		1.996 58.898 1.848 59.289 1.848 c 59.621 1.848 59.867 1.953 60.039 2.16
		c 60.16 2.312 60.223 2.496 60.223 2.707 c 60.223 3 60.102 3.227 59.859 
		3.387 c 59.754 3.449 59.492 3.555 59.066 3.699 c 58.648 3.844 58.34 3.996
		58.148 4.16 c 57.879 4.391 57.746 4.695 57.746 5.07 c 57.746 5.434 57.867
		5.738 58.105 5.98 c 58.375 6.254 58.727 6.391 59.168 6.391 c 59.539 6.391
		59.859 6.289 60.125 6.094 c 60.371 5.918 60.535 5.688 60.625 5.406 c 60.656
		5.301 60.68 5.156 60.695 4.984 c 60.078 4.984 l 60.062 5.207 60.012 5.383
		59.922 5.512 c 59.754 5.754 59.504 5.871 59.172 5.871 c 58.934 5.871 58.738
		5.801 58.594 5.664 c 58.441 5.516 58.363 5.324 58.363 5.094 c 58.363 4.832
		58.48 4.625 58.715 4.469 c 58.84 4.391 59.07 4.293 59.41 4.188 c 59.711
		4.09 59.902 4.02 59.984 3.984 c 60.562 3.719 60.852 3.312 60.852 2.762 
		c 60.852 2.359 60.711 2.023 60.438 1.75 c 60.148 1.469 59.77 1.324 59.293
		1.324 c 58.656 1.324 58.188 1.57 57.898 2.062 c 57.766 2.289 57.688 2.582
		57.664 2.941 c f
		63.617 2.629 m 64.164 2.629 l 64.156 2.371 64.082 2.125 63.93 1.898 c 63.684
		1.523 63.336 1.336 62.875 1.336 c 62.41 1.336 62.055 1.508 61.805 1.855
		c 61.562 2.184 61.445 2.602 61.445 3.109 c 61.445 3.602 61.559 4.008 61.781
		4.332 c 62.039 4.695 62.398 4.879 62.863 4.879 c 63.277 4.879 63.605 4.73
		63.852 4.438 c 64 4.258 64.098 4.02 64.148 3.723 c 63.594 3.723 l 63.559
		3.902 63.504 4.047 63.43 4.156 c 63.289 4.348 63.102 4.445 62.871 4.445
		c 62.602 4.445 62.391 4.324 62.238 4.09 c 62.074 3.836 61.992 3.512 61.992
		3.113 c 61.992 2.707 62.07 2.379 62.227 2.129 c 62.383 1.891 62.598 1.773
		62.875 1.773 c 63.141 1.773 63.344 1.902 63.48 2.164 c 63.551 2.289 63.598
		2.441 63.617 2.629 c f
		Q			
		q
		0.886275 0 0.454902 rg 
		69.035 2.965 m 66.836 2.965 l 66.84 2.742 66.871 2.547 66.93 2.379 c 67.07
		1.977 67.332 1.773 67.707 1.773 c 68 1.773 68.215 1.898 68.344 2.152 c 
		68.391 2.242 68.434 2.363 68.477 2.504 c 69 2.504 l 68.949 2.234 68.859 
		2.008 68.727 1.832 c 68.484 1.5 68.148 1.336 67.711 1.336 c 67.23 1.336 
		66.863 1.52 66.613 1.891 c 66.395 2.215 66.285 2.625 66.285 3.117 c 66.285
		3.633 66.41 4.055 66.664 4.387 c 66.914 4.715 67.25 4.879 67.672 4.879 
		c 68.023 4.879 68.316 4.773 68.547 4.555 c 68.797 4.316 68.949 3.961 69.004
		3.492 c 69.02 3.352 69.031 3.176 69.035 2.965 c 68.48 3.402 m 68.465 3.641
		68.422 3.84 68.352 3.996 c 68.215 4.293 67.992 4.445 67.684 4.445 c 67.391
		4.445 67.168 4.309 67.023 4.035 c 66.934 3.867 66.871 3.656 66.84 3.402
		c h
		68.48 3.402 m f
		69.848 1.441 m 69.848 4.777 l 70.352 4.777 l 70.352 4.328 l 70.598 4.695
		70.93 4.879 71.344 4.879 c 71.59 4.879 71.801 4.812 71.973 4.684 c 72.152
		4.543 72.262 4.348 72.305 4.086 c 72.324 3.98 72.332 3.816 72.332 3.598
		c 72.332 1.441 l 71.793 1.441 l 71.793 3.406 l 71.793 3.707 71.773 3.926
		71.738 4.055 c 71.707 4.172 71.641 4.266 71.543 4.336 c 71.445 4.41 71.328
		4.445 71.191 4.445 c 70.949 4.445 70.754 4.348 70.609 4.152 c 70.508 4.023
		70.445 3.848 70.418 3.637 c 70.398 3.504 70.387 3.312 70.387 3.059 c 70.387
		1.441 l h
		69.848 1.441 m f
		75.289 2.629 m 75.836 2.629 l 75.828 2.371 75.75 2.125 75.602 1.898 c 75.355
		1.523 75.008 1.336 74.547 1.336 c 74.082 1.336 73.723 1.508 73.473 1.855
		c 73.234 2.184 73.117 2.602 73.117 3.109 c 73.117 3.602 73.227 4.008 73.453
		4.332 c 73.707 4.695 74.066 4.879 74.535 4.879 c 74.949 4.879 75.277 4.73
		75.523 4.438 c 75.672 4.258 75.77 4.02 75.82 3.723 c 75.262 3.723 l 75.23
		3.902 75.176 4.047 75.102 4.156 c 74.961 4.348 74.773 4.445 74.539 4.445
		c 74.273 4.445 74.062 4.324 73.91 4.09 c 73.746 3.836 73.664 3.512 73.664
		3.113 c 73.664 2.707 73.742 2.379 73.898 2.129 c 74.055 1.891 74.27 1.773
		74.547 1.773 c 74.812 1.773 75.016 1.902 75.152 2.164 c 75.223 2.289 75.266
		2.441 75.289 2.629 c f
		79.121 2.965 m 76.922 2.965 l 76.926 2.742 76.957 2.547 77.016 2.379 c 
		77.16 1.977 77.418 1.773 77.793 1.773 c 78.09 1.773 78.301 1.898 78.43 2.152
		c 78.477 2.242 78.523 2.363 78.562 2.504 c 79.086 2.504 l 79.035 2.234 
		78.945 2.008 78.812 1.832 c 78.574 1.5 78.234 1.336 77.801 1.336 c 77.316
		1.336 76.949 1.52 76.703 1.891 c 76.48 2.215 76.371 2.625 76.371 3.117 
		c 76.371 3.633 76.5 4.055 76.754 4.387 c 77.004 4.715 77.34 4.879 77.762
		4.879 c 78.109 4.879 78.402 4.773 78.633 4.555 c 78.883 4.316 79.035 3.961
		79.09 3.492 c 79.105 3.352 79.117 3.176 79.121 2.965 c 78.57 3.402 m 78.555
		3.641 78.508 3.84 78.438 3.996 c 78.301 4.293 78.078 4.445 77.77 4.445 
		c 77.477 4.445 77.258 4.309 77.109 4.035 c 77.02 3.867 76.961 3.656 76.93
		3.402 c h
		78.57 3.402 m f
		79.656 2.383 m 80.215 2.383 l 80.227 1.984 80.445 1.789 80.863 1.789 c 
		81.066 1.789 81.223 1.84 81.32 1.938 c 81.406 2.023 81.449 2.137 81.449 
		2.277 c 81.449 2.461 81.352 2.613 81.16 2.734 c 81.086 2.777 80.91 2.855
		80.633 2.965 c 80.332 3.082 80.117 3.207 79.992 3.344 c 79.84 3.512 79.762
		3.719 79.762 3.961 c 79.762 4.246 79.859 4.477 80.066 4.648 c 80.246 4.805
		80.488 4.879 80.789 4.879 c 81.223 4.879 81.531 4.734 81.715 4.441 c 81.805
		4.301 81.859 4.125 81.879 3.918 c 81.34 3.918 l 81.332 4.062 81.289 4.18
		81.215 4.27 c 81.113 4.391 80.969 4.449 80.785 4.449 c 80.613 4.449 80.484
		4.402 80.395 4.301 c 80.324 4.223 80.289 4.121 80.289 3.996 c 80.289 3.855
		80.336 3.746 80.43 3.664 c 80.523 3.586 80.703 3.492 80.977 3.391 c 81.328
		3.262 81.574 3.137 81.715 3.02 c 81.93 2.84 82.035 2.609 82.035 2.332 c
		82.035 2.031 81.93 1.785 81.723 1.598 c 81.527 1.426 81.258 1.336 80.91
		1.336 c 80.395 1.336 80.035 1.5 79.836 1.824 c 79.727 1.992 79.668 2.18
		79.656 2.383 c f
		Q}
	\end{picture}
}
}
% ----------------------------------------------------

% ----------------------------------------------------
% Variable definitions and default values
\newcommand{\theUniversity}{Hochschule für Telekommunikation Leipzig (FH)}
\newcommand{\theInstitute}{Institut für Telekommunikationsinformatik}
\newcommand{\theDocumentKind}{Abschlussarbeit zur Erlangung des akademischen Grades}
\newcommand{\theForDegree}{Bachelor of Engineering}
\newcommand{\theTopic}{Mein tolles \enquote{Abschlussthema}}
\title{\theTopic}
\newcommand{\theThesisAuthor}{Max Mustermann}
\author{\theThesisAuthor}
\newcommand{\theAuthorDateOfBirth}{01.01.2018}
\newcommand{\theAuthorPlaceOfBirth}{Leipzig}


\newcommand{\theHandInDate}{\today}
\date{\theHandInDate}

\newcommand{\theFirstReviewerName}{Prof. Dr. Detlef Musterdude}
\newcommand{\theFirstReviewerInstitution}{Hochschule für Telekommunikation Leipzig}
\newcommand{\theFirstReviewerInstitutionStreet}{Gustav-Freytag-Straße 43-45}
\newcommand{\theFirstReviewerInstitutionPlace}{04277 Leipzig}

\newcommand{\theSecondReviewerName}{Dipl.-Ing. (FH) Monika Musterfrau}
\newcommand{\theSecondReviewerInstitution}{Hochschule für Telekommunikation Leipzig}
\newcommand{\theSecondReviewerInstitutionStreet}{Gustav-Freytag-Straße 43-45}
\newcommand{\theSecondReviewerInstitutionPlace}{04277 Leipzig}

\newcommand{\university}[1]{\renewcommand{\theUniversity}{#1}}
\newcommand{\institute}[1]{\renewcommand{\theInstitute}{#1}}
\newcommand{\documentKind}[1]{\renewcommand{\theDocumentKind}{#1}}
\newcommand{\forDegree}[1]{\renewcommand{\theForDegree}{#1}}

\newcommand{\topic}[1]{\renewcommand{\theTopic}{#1}\title{#1}}
\newcommand{\thesisAuthor}[1]{\renewcommand{\theThesisAuthor}{#1}\author{#1}}


\newcommand{\authorDateOfBirth}[1]{\renewcommand{\theAuthorDateOfBirth}{#1}}
\newcommand{\authorPlaceOfBirth}[1]{\renewcommand{\theAuthorPlaceOfBirth}{#1}}

\newcommand{\handInDate}[1]{\renewcommand{\theHandInDate}{#1}\date{#1}}

\newcommand{\firstReviewerName}[1]{\renewcommand{\theFirstReviewerName}{#1}}
\newcommand{\firstReviewerInstitution}[1]{\renewcommand{\theFirstReviewerInstitution}{#1}}
\newcommand{\firstReviewerInstitutionStreet}[1]{\renewcommand{\theFirstReviewerInstitutionStreet}{#1}}
\newcommand{\firstReviewerInstitutionPlace}[1]{\renewcommand{\theFirstReviewerInstitutionPlace}{#1}}

\newcommand{\secondReviewerName}[1]{\renewcommand{\theSecondReviewerName}{#1}}
\newcommand{\secondReviewerInstitution}[1]{\renewcommand{\theSecondReviewerInstitution}{#1}}
\newcommand{\secondReviewerInstitutionStreet}[1]{\renewcommand{\theSecondReviewerInstitutionStreet}{#1}}
\newcommand{\secondReviewerInstitutionPlace}[1]{\renewcommand{\theSecondReviewerInstitutionPlace}{#1}}
% ----------------------------------------------------

% ----------------------------------------------------
% Definition of the titlepage
\makeatletter
\renewcommand{\coverpagetopmargin}{0em}
\renewcommand{\coverpagebottommargin}{0em}
\renewcommand{\maketitle}{	
\begin{titlepage}
	\begin{figure}[h]
		\raggedleft
		\inserthftllogo[180px]
	\end{figure}
	\normalfont		
	\begin{center}
		\Large
		\theUniversity\\
		\smallskip
		\large
		\theInstitute
	\end{center}
	
	\vfill
	
	\begin{center}
		\large\sffamily
		\textbf{\theDocumentKind}\\
		\smallskip
		\textbf{\theForDegree}\par
	\end{center}
	\vfill
	
	\begin{table}[htb]
		\begin{tabular}{lp{11cm}}
			\topiccaption: & \large \@title \vfill\\
			\submittedbycaption: & \@author\\
			\dateofbirthcaption: & \theAuthorDateOfBirth\\
			\placeofbirthcaption: & \theAuthorPlaceOfBirth
			\vfill\\
			\submittedcaption: & \@date\vfill\\
			\firstreviewercaption: & \theFirstReviewerName\\\\
			& \theFirstReviewerInstitution\\
			& \theFirstReviewerInstitutionStreet\\
			& \theFirstReviewerInstitutionPlace\\\\
			\secondreviewercaption: &  \theSecondReviewerName\\\\
			& \theSecondReviewerInstitution\\
			& \theSecondReviewerInstitutionStreet\\
			& \theSecondReviewerInstitutionPlace\\\\
		\end{tabular}
	\end{table}
\end{titlepage}
}
\makeatother
% ----------------------------------------------------

% ----------------------------------------------------
% Definition of the declaration of authorship
\newcommand{\makedeclarationofauthorship}{
\addchap{\declarationofauthorshipcaption}
\declarationofauthorshipstatementonecaption 
\begin{center}
	\textbf{\theTopic}
\end{center}  
\declarationofauthorshipstatementtwocaption

\vspace{1cm}
Leipzig, \dencaption \theHandInDate


\vspace{2cm}
\begin{flushright}
	\begin{tabular}{c}
		\hline
		\hspace{2em}\theThesisAuthor\hspace{2em}
	\end{tabular}
\end{flushright}
}
% ----------------------------------------------------
