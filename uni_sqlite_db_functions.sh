#!/bin/bash

# Store all functions for SQLite DataBase interactions.

	# 1 database should be ok here.
	# Tables:
	#		PIDs - list attached to program/scripts name? More than one script could be in action, so a list of PIDs in this table.
	#		PanS - Program and Scripts details. Shows the names and locations and last accessed and last updated. PIDs links to this.
	#		HostsInfo - Every hosts information is in here. IPs, Phishical location, Network, Group, First installed, etc
	#		LOGS - Log all data in raw format for later researching.
	#		PassingCommands - When commands are picked-up(File input, ssh passed in, URL location), store them in here with DATE/Time so we have an order to execute them.

###
# Helper URLs
###
# http://www.thegeekstuff.com/2012/09/sqlite-command-examples/
# http://www.sqlite.org/cli.html
#

#Special commands to sqlite3

#Most of the time, sqlite3 just reads lines of input and passes them on to the SQLite library for execution. But if an input line begins with a dot ("."), then that line is intercepted and interpreted by the sqlite3 program itself. These "dot commands" are typically used to change the output format of queries, or to execute certain prepackaged query statements.

#For a listing of the available dot commands, you can enter ".help" at any time. For example:

#sqlite> .help
#.backup ?DB? FILE      Backup DB (default "main") to FILE
#.bail ON|OFF           Stop after hitting an error.  Default OFF
#.clone NEWDB           Clone data into NEWDB from the existing database
#.databases             List names and files of attached databases
#.dump ?TABLE? ...      Dump the database in an SQL text format
                         #If TABLE specified, only dump tables matching
                         #LIKE pattern TABLE.
#.echo ON|OFF           Turn command echo on or off
#.exit                  Exit this program
#.explain ?ON|OFF?      Turn output mode suitable for EXPLAIN on or off.
                         #With no args, it turns EXPLAIN on.
#.header(s) ON|OFF      Turn display of headers on or off
#.help                  Show this message
#.import FILE TABLE     Import data from FILE into TABLE
#.indices ?TABLE?       Show names of all indices
                         #If TABLE specified, only show indices for tables
                         #matching LIKE pattern TABLE.
#.load FILE ?ENTRY?     Load an extension library
#.log FILE|off          Turn logging on or off.  FILE can be stderr/stdout
#.mode MODE ?TABLE?     Set output mode where MODE is one of:
                         #csv      Comma-separated values
                         #column   Left-aligned columns.  (See .width)
                         #html     HTML <table> code
                         #insert   SQL insert statements for TABLE
                         #line     One value per line
                         #list     Values delimited by .separator string
                         #tabs     Tab-separated values
                         #tcl      TCL list elements
#.nullvalue STRING      Use STRING in place of NULL values
#.open ?FILENAME?       Close existing database and reopen FILENAME
#.output FILENAME       Send output to FILENAME
#.output stdout         Send output to the screen
#.print STRING...       Print literal STRING
#.prompt MAIN CONTINUE  Replace the standard prompts
#.quit                  Exit this program
#.read FILENAME         Execute SQL in FILENAME
#.restore ?DB? FILE     Restore content of DB (default "main") from FILE
#.save FILE             Write in-memory database into FILE
#.schema ?TABLE?        Show the CREATE statements
                         #If TABLE specified, only show tables matching
                         #LIKE pattern TABLE.
#.separator STRING      Change separator used by output mode and .import
#.show                  Show the current values for various settings
#.stats ON|OFF          Turn stats on or off
#.tables ?TABLE?        List names of tables
                         #If TABLE specified, only list tables matching
                         #LIKE pattern TABLE.
#.timeout MS            Try opening locked tables for MS milliseconds
#.trace FILE|off        Output each SQL statement as it is run
#.vfsname ?AUX?         Print the name of the VFS stack
#.width NUM1 NUM2 ...   Set column widths for "column" mode
#.timer ON|OFF          Turn the CPU timer measurement on or off
#sqlite>
#Rules for "dot-commands"

#Ordinary SQL statements are very much free-form, can be spread across multiple lines, and can have whitespace and comments anywhere. But dot-commands are not like that. The dot-commands are more restrictive:

#A dot-command must begin with the "." at the left margin with no preceding whitespace.
#The dot-command must be entirely contained on a single input line.
#A dot-command cannot occur in the middle of an ordinary SQL statement. In other words, a dot-command cannot occur at a continuation prompt.
#Dot-commands do not recognize comments.
#And, of course, it is important to remember that the dot-commands are interpreted by the sqlite3.exe command-line program, not by SQLite itself. So none of the dot-commands will work as an argument to SQLite interfaces like sqlite3_prepare() or sqlite3_exec().

# Find all needed commands
rm_command=$(loc_file "rm" "/bin /sbin /usr/bin /usr/sbin")
sqlite3_command=$(loc_file "sqlite3" "/usr/bin")


# Clean Input Data


# Select DataBase
	function select_db() { # selected_db_file(Location Optional)
		if [ "$1" != "" ]; then
			echo "$1 database selected"
			selected_db_file="$1"
		fi
	}


# Delete DataBase
	function delete_db() { # $1 pass the database file to delete. You should have already moved to another database file with Select_DB()
			echo "Delete Database $1"
			$rm_command -f "$1"
	}


# Create DataBase if missing(First Run I hope)
	# Check if the DB File exists. If not, create it and fill it with structure.
	# STRUCTURE="CREATE TABLE if not exists wpapasses (id INTEGER PRIMARY KEY,prioritylvl INTEGER,pass TEXT);";
	function create_db_and_fill() { # selected_db_file(Location Optional), Table setup string

		# Assign vars
		if [ "$1" != "" ]; then
			selected_db_file="$1"
		fi
		if [ "$2" != "" ]; then
			table_structure="$2"
		fi

		#Create file if it does not exists
		if [ ! -f "$selected_db_file" ]; then
			touch "$selected_db_file"

			# Creating an Empty db file and filling it with my structure
			cat /dev/null > "$selected_db_file"
			echo "$table_structure" > tmpstructure
			$sqlite3_command "$selected_db_file" < tmpstructure;

			$rm_command -f tmpstructure
		else
			echo "DB File already exists. I'm not overwriting it!"
		fi
	}

# Rename DataBase ?
# This command should only be run after all other processes are done with it
	function rename_db() { # current_db name as $1, new_db name as $2
		mv "$1" "$2"
	}

# Select Table
# This sets the variable to use in the other functions. Just like Select_DB()
	function select_table() { # $1 will set the variable.
		selected_table="$1"
	}

# Delete Table
	function delete_table() { # $1 = the table name. Don't rely on the Select_table() for deleting things. Specifiy for safety.
		echo "Deleting $selected_db_file.$1"
		$sqlite3_command "drop table if exists $selected_db_file.$1"
	}

# Create Table
	#Basic syntax of CREATE TABLE statement is as follows:

	#CREATE TABLE IF NOT EXISTS database_name.table_name(
	   #column1 datatype  PRIMARY KEY(one or more columns),
	   #column2 datatype,
	   #column3 datatype,
	   #.....
	   #columnN datatype,
	#);
	function create_table() { # $1 = string of commands as exampled above. $2 = boolean. TRUE if you want to switch the currently selected table to the one just created.
		echo "Creating table $selected_db_file.$1"
		$sqlite3_command "$selected_db_file.$1"

		if [ "$2" == "TRUE" ]; then
			select_table "$1"
		fi

	}

# Rename Table
	function rename_table() { # $1 old name to $2 new name
		echo "Renaming table $1 to $2"
		$sqlite3_command "ALTER TABLE $1 RENAME TO $2"
	}

# Add/Remove Column from Table
	function add_remove_column() { $1 = The New column name and the datatype. Ex. $1="email string"
		echo "Adding to $selected_table column $1"
		$sqlite3_command "ALTER TABLE $selected_table ADD COLUMN $1"

	}

# Select Row(s)
# Grab output like this, sql_output="$( select_query 'Title,ISBN' 'title' 'Lord of the Rings')"
# $1 = table
# $2 = column to find
# $3 = value in column
	function select_query() {
		$sqlite3_command "SELECT $1 WHERE $2 = '$3'"
	}

# Delete Row(s)
	function delete_rows() {
		$sqlite3_command "DELETE FROM $1 WHERE $2 = '$3'"
	}

# Update Row(Will do a INSERT if the entry is missing for UPDATing)
# Need to do a loop for each entry.
# $1 = Column(s) to update. Space seperated.
# $2 = Values for the Columns
# $3 = column to find
# $4 = value in column
	function update_row() {
		array_column1=($1)
		array_column2=($2)
		count=${#array1[@]}
		for i in `seq 1 $count`
		do
			x=${array1[$i-1]}
			y=${array2[$i-1]}
			$sqlite3_command "UPDATE $selected_table SET $x = '$y' WHERE $3 = '$4'"
		done
	}

# Select Cell


# Delete Cell(Set to NULL)
# $1 = Column to alter. $2 = the WHERE Column. $3 = the WHERE value.
	function delete_cell() {
		$sqlite3_command "UPDATE $selected_table SET $1 = NULL WHERE $2 = '$3'" # UPDATE COMPANY SET ADDRESS = 'Texas' WHERE ID = 6;
	}

# Update Cell(Will do a INSERT if the entry is missing for UPDATing)
# $1 = string of SQL.
	function update_cell() {
		# First try a INSERT, If it errors, do an update.
		# Idealy, we would use a "INSERT ... ON DUPLICATE KEY UPDATE", but sqlite3 seems to not have it.
		# http://blog.client9.com/2007/11/21/sqlite3-and-on-duplicate-key-update.html
		#
		# $1 = Column to alter. $2 = The value for it. $3 = the WHERE Column. $4 = the WHERE value.
		# Make sure you use select_table() before using this function. Set the table first!
		# EG: update_cell "Title" "Lord of the Rings" "ID" "6"
		$sqlite3_command "UPDATE $selected_table SET $1 = '$2' WHERE $3 = '$4'" # UPDATE COMPANY SET ADDRESS = 'Texas' WHERE ID = 6;
		if [ $? -gt 0 ]; then
			$sqlite3_command "INSERT INTO $selected_table($1) VALUES('$2')" # INSERT INTO Books(Title) VALUES('War and Peace');
		fi

	}

# Raw SQL
# Simply pass raw code on $1
	function raw_sql() {
		$sqlite_command "$1"
	}

# Import Data ?

# Export Data ?

