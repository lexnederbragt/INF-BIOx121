for f in $(find . -name "*.md"); do outname=$(echo $f|sed 's/.md/.rst/'); echo $f; pandoc -f markdown -t rst $f  > $outname; done

