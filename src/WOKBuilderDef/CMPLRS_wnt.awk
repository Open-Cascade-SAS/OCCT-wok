BEGIN {
	FS="\"[ \t]*";
}
/#line 1 / {
	gsub("[\\]","/",$2);
	gsub("//","/", $2);
	print $2
}
