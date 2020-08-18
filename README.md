# HfTL-Thesis Template

This is a LaTeX template following the design recommendations for theses at the HfTL. Created by [Martin Meszaros](mailto:meszaros@hft-leipzig.de) for [Hochschule für Telekommunikation Leipzig](https://www.hft-leipzig.de).

[**Download the thesis template**](https://hftl-internal.gitlab.io/hftl-thesis-template/hftl-thesis-template.zip).

See the [example document](https://hftl-internal.gitlab.io/hftl-thesis-template/my-thesis.pdf) for how to use it and check out the comments of the `my-thesis.tex` file and `hftlthesis.cls` file. Also have a look at the [LaTeX Cheat Sheet](http://mirrors.ctan.org/info/latex-refsheet/LaTeX_RefSheet.pdf) for commonly used commands.

## Getting started

1. Install a LaTeX distribution:

	 - Windows: [MikTeX](https://miktex.org/) (recommended) or [TeX Live](https://tug.org/texlive/)
	 - Linux: [TeX Live](https://tug.org/texlive/) (install from your package manager)
	 - Mac: [MacTeX](http://www.tug.org/mactex/)

2. Install your LaTeX editor of choice, for example [TeXstudio](https://www.texstudio.org/) or [Visual Studio Code](https://code.visualstudio.com/) with the [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) extension.

3. (Optional) Install [LanguageTool](https://languagetool.org#standalone) (Java required) for advanced spell- and grammar checking. See the screenshot below for the required settings to make it work with TeXstudio.
![TeXstudio settings for LanguageTool](https://i.imgur.com/6J5rJqv.png)

4. (Optional) For bibliography management use a tool like [Zotero](https://www.zotero.org/) with the [Better BibTeX](https://github.com/retorquere/zotero-better-bibtex) extension.

## Notes

 - If you use **MikTeX as your LaTeX distribution**, the first compilation might take some time and it might ask for administrator privileges, as it installs the required packages.
 - If **TeXstudio autocompletion** does not correctly work, copy the completion file `hftlthesis.cwl` from the archive to `%APPDATA%\texstudio\completion\user` (Windows) or `~/.config/texstudio/completion/user` (Linux/Mac).
 - Depending on your Linux distribution, the installation of TeX Live alone might not be sufficient. For Ubuntu (>=16.04), the required packages can be installed by the command: `sudo apt install texlive texlive-latex-extra texlive-fonts-extra texlive-science texlive-lang-german texlive-lang-cyrillic texlive-generic-extra texlive-bibtex-extra biber`. If you use another distribution, make sure that the following **packages have to be installed**:
	 
	 - `etoolbox`
	 - `scrbook`
	 - `inputenc`
	 - `xifthen`
	 - `XCharter`
	 - `opensans`
	 - `sourcecodepro`
	 - `fontenc`
	 - `babel`
	 - `biblatex`
	 - `graphicx`
	 - `csquotes`
	 - `ragged2e`
	 - `datetime2`
	 - `amsmath`
	 - `multirow`
	 - `longtable`
	 - `tabularx`
	 - `needspace`
	 - `enumitem`
	 - `booktabs`
	 - `microtype`
	 - `hyperref`
	 - `glossaries`

	 **The demo document additionally requires:**
	 - `blindtext`
	 - `tikz`
	 - `pgfplots`
	 - `listings`
	 - `siunitx`