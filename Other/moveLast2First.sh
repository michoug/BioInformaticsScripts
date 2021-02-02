#Move last line of a file to the 1st line

sed '1h;1d;$!H;$!d;G'
