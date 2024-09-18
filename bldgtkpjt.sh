#!/bin/bash

#Script to build a basic GTK application project.
# Set Variables
Name="Untitled"
Path=""

###########################################################
# Help                                                     #
############################################################
Help() {
   # Display Help
   echo "Build a GTK project"
   echo
   echo "Syntax: bldgtkpjt.sh [-n|o|h]"
   echo "options:"
   echo "n     Name of the project"
   echo "o     Path to output folder"
   echo "h     Prints this help"
   echo "EX: ./bldgtkpgt.sh -n test -o /home/user_name/projects"
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":n:o:" option; do
   case $option in
      n) # Enter a name
         Name=${OPTARG}
         ;;
      o) # Enter a path
         Path=${OPTARG}
         ;;
     \?) # Invalid option
         echo "Error: Invalid option"
         Help
         exit;;
   esac
done

if [ -z "$Path" ]
then
    echo "\$Path is empty"
    exit
fi

if [ -z "$Name" ]
then
    echo "\$Name is empty"
    exit
fi

NOW=$(date +'%Y-%m-%d %H:%M:%S')

mkdir -p ${Path}/${Name}/bin ${Path}/${Name}/src ${Path}/${Name}/include ${Path}/${Name}/build ${Path}/${Name}/rsc ${Path}/${Name}/.vscode

# README.md
touch ${Path}/${Name}/README.md
cat > ${Path}/${Name}/README.md <<EOL
# ${Name^} Application
	- Created on: ${NOW}
	- Author: <Name>
	- Email: <Email>
	

This is an auto-generated README file.
EOL

# AutoTools.sh
touch ${Path}/${Name}/autotools.sh
chmod +x ${Path}/${Name}/autotools.sh

touch ${Path}/${Name}/configure.ac
cat > ${Path}/${Name}/configure.ac <<EOL
AC_PREREQ([2.71])
AC_INIT([${Name}], [0.0.1], [])
AC_CONFIG_SRCDIR([src/main.cc])
AC_CONFIG_HEADERS([config.h])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

# Checks for programs

# Compiler variable override
if test -z \$CXXFLAGS; then
    CXXFLAGS='-g'
fi

# Use g++ compiler
AC_PROG_CXX

# Checks for libraries
PKG_CHECK_MODULES([GTK4], gtkmm-4.0, [], AC_MSG_ERROR([Failed to find GTK4]))

# Checks for header files

# Checks for typedefs, structures, and compiler characteristics

# Checks for library functions

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
EOL

cat > ${Path}/${Name}/autotools.sh <<EOL
#!/bin/bash

function help() {
cat <<EOH
This script is auto-generated. Its purpose is to automate the 
autotools process for building Gtk projects. Autotools can be 
complicated taking many rigid steps to accomplish. 
Hopefully this script will be useful for programmers who are
not familiar with the gnu tools for building projects.

USAGE:
  NOTE: Use only one (1) option at a time.

  autotools.sh [options]

OPTIONS:
  -a			# Run all scripts
  -b			# Builds the project
  -c			# Configure the project
  -d			# A conveyance option that builds with the clean flag
  -h			# This help menu
  -i			# Installs the linux project to the system. Must use 'sudo' for permissions
  -k			# Clean all autotool files
  -s			# Scans and auto-generates the Makefile.am file
  -u			# Uninstalls the previously installed linux project. Must use 'sudo' for permissions

EXAMPLES:
  autotools.sh -a	# Runs all the scripts to build the project
  autotools.sh -b	# Builds the project
  autotools.sh -d	# Clean and build the project
  autotools.sh -k	# Cleans the project of all auto-generated files

EOH

}

function cleanbuild() {

	if [[ -d "./build" ]]; then
		cd ./build
		make clean
		make -j4

		# MOVE EXECUTABLE TO BIN FOLDER
		if [[ -f "./${Name}" ]]; then
			cp -f ./${Name} ../bin/${Name}
			echo "${Name} successfully copied to bin directory"
		fi

		cd ..
	fi
}

function build() {

	if [[ -d "./build" ]]; then
		cd ./build

		# CLEAN IF REQUESTED
		if [ \$clean -eq true ]; then
			make clean
		fi
		
		make -j4

		# MOVE EXECUTABLE TO BIN FOLDER
		if [[ -f "./${Name}" ]]; then
			cp -f ./${Name} ../bin/${Name}
			echo "${Name} successfully copied to bin directory"
		fi

		cd ..
	fi
}

function configure() {
	aclocal
	sleep 1
	automake --add-missing
	sleep 1
	autoreconf

	if [[! -d "./build" ]]; then
		mkdir ./build
	fi

	if [[ -d "./build" ]]; then
		cd ./build
		../configure;
		cd ..
	fi

	echo 'Configure is complete'
}

function install() {
	rm -rf /usr/local/share/${Name}
	mkdir /usr/local/share/${Name}
	cp bin/${Name} /usr/local/share/${Name}/${Name}
	cp rsc/${Name}.png rsc/${Name}.svg /usr/local/share/${Name}/
	cp -f rsc/${Name}.desktop /usr/share/applications/${Name}.desktop
}

function uninstall() {
	rm -rf /usr/local/share/${Name}
	rm -f /usr/share/applications/${Name}.desktop
}

function scan() {
	if [[ -f "./Makefile.am" ]]; then
		rm -f ./Makefile.am
	fi

	lastfile=\$(ls "./include/" | tail -1)

	# Rebuild the Makefile.am file
	echo "#Regenerated Makefile.am from scan.sh" > ./Makefile.am
	echo "" >> ./Makefile.am
	echo "AUTOMAKE_OPTIONS = subdir-objects" >> ./Makefile.am
	echo "" >> ./Makefile.am
	echo "bin_PROGRAMS = ${Name}" >> ./Makefile.am
	echo "" >> ./Makefile.am
	echo "${Name}_CPPFLAGS = @GTK4_CFLAGS@ -I../include/ -std=c++20" >> ./Makefile.am 
	echo "" >> ./Makefile.am
	echo "${Name}_LDADD = @GTK4_LIBS@" >> ./Makefile.am
	echo "" >> ./Makefile.am
	echo "${Name}_SOURCES = \\\\" >> ./Makefile.am
EOF

	for file in ./src/*; do
		# process each file
		types=(*.cpp *.c++ *.cc)
		for type in "\${types[@]}"; do
			if [ "\${type##*.}" = "cpp" ]; then
				echo -e "\tsrc/\${file##*/} \\\\" >> ./Makefile.am
			fi
		done
	done

	for file in ./include/*; do
		# process each file
		types=(*.h *.hpp *.hh *.xpm *.ui)
		
		for type in "\${types[@]}"; do
			if [ "\${type##*.}" = "hpp" ]; then
				if [[ "\${file##*/}" == "\$lastfile" ]]; then
					echo -e "\tinclude/\${file##*/}" >> ./Makefile.am
				else
					echo -e "\tinclude/\${file##*/} \\\\" >> ./Makefile.am
				fi
			fi
		done
	done

	echo "Makefile.am has been regenerated"
}

function clean() {
	if [[ -d "./build" ]]; then
		cd ./build

		if [[ -f "./Makefile" ]]; then
			make clean
			make maintainer-clean
		fi
		
		cd ..
	else
		mkdir ./build
	fi

	if [[ -f "./aclocal.m4" ]]; then
		rm -f ./aclocal.m4
	fi

	if [[ -f "./autom4te.cache" ]]; then
		rm -rf ./autom4t3.cache
	fi

	if [[ -f "./config.h.in" ]]; then
		rm -f ./config.h.in
	fi

	if [[ -f "./configure" ]]; then
		rm -f ./configure
	fi

	if [[ -f "./configure~" ]]; then
		rm -f ./configure~
	fi

	if [[ -f "./depcomp" ]]; then
		rm -f ./depcomp
	fi

	if [[ -f "./Makefile.in" ]]; then
		rm -f ./Makefile.in
	fi

	if [[ -f "./Makefile.am" ]]; then
		rm -f ./Makefile.am
	fi

	if [[ -f "./Makefile.am~" ]]; then
		rm -f ./Makefile.am~
	fi

	if [[ -f "./missing" ]]; then
		rm -f ./missing
	fi

	if [[ -f "./COPYING" ]]; then
		rm -f ./COPYING
	fi

	if [[ -f "./INSTALL" ]]; then
		rm -f ./INSTALL
	fi

	if [[ -f "./install-sh" ]]; then
		rm -f ./install-sh
	fi

	echo 'Project has been cleaned of all autotools files'
}

function all() {
	clean
	scan
	configure
	build
}

while getopts "abcdhiksu" opt; do
	case \$opt in
		a) all ;;
		c) configure ;;
		b) build ;;
		d) cleanbuild ;;
		h) help ;;
		i) install ;;
		k) clean ;;
		s) scan ;;
		u) uninstall ;;
		\?) help ;;
	esac
done
EOL

# Code Workspace File

touch ${Path}/${Name}/${Name}.code-workspace 

cat > ${Path}/${Name}/${Name}.code-workspace <<EOL
{
	"folders": [
		{
			"path": "."
		}
	],
	"settings": {
		"files.associations": {
			"string": "cc"
		}
	}
}

EOL

# VSCODE File

cp rsc/c_cpp_properties.json ${Path}/${Name}/.vscode/c_cpp_properties.json
touch ${Path}/${Name}/.vscode/launch.json

cat > ${Path}/${Name}/.vscode/launch.json <<EOL
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) Launch",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/bin/${Name}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Set Disassembly Flavor to Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
EOL

# Prog Desktop File
cp rsc/icon.png ${Path}/${Name}/rsc/${Name}.png
cp rsc/icon.svg ${Path}/${Name}/rsc/${Name}.svg

touch ${Path}/${Name}/rsc/${Name}.desktop

cat > ${Path}/${Name}/rsc/${Name}.desktop <<EOL
[Desktop Entry]
Name=${Name}
# Translators: Search terms to find this application. Do NOT translate or localize the semicolons! The list MUST also end with a semicolon!
Keywords=utilities
Comment=Scott Combs Code
GenericName=${Name}
Exec=/usr/local/share/${Name}/${Name}
# Translators: Do NOT translate or transliterate this text (this is an icon file name)!
Icon=/usr/local/share/${Name}/${Name}.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Utilities;

EOL

# Main.cc File

touch ${Path}/${Name}/src/main.cc 

cat > ${Path}/${Name}/src/main.cc <<EOL
#include <mainwindow.h>

int main(int argc, char* argv[]) {

    Glib::RefPtr<Gtk::Application> app = Gtk::Application::create("org.gtkmm.examples.base");
    
    return app->make_window_and_run<MainWindow>(argc, argv);
}

EOL

# MainWindow.cc File

touch ${Path}/${Name}/src/mainwindow.cc 

cat > ${Path}/${Name}/src/mainwindow.cc <<EOL
#include <mainwindow.h>

MainWindow::MainWindow() {
    this->set_ui();
}

void MainWindow::set_ui() {
    // This just sets the title of our new window.
    this->set_title("Msg Box");

    this->set_default_size(200, 100);

    // Sets the margin around the box.
    this->m_box1.set_margin(10);
    this->m_box1.set_homogeneous(false);

    // put the box into the main window.
    this->set_child(this->m_box1);

    // Add the button
    this->m_btn1.set_label("Click Me");
    this->m_btn1.set_size_request(90,24);
    this->m_btn1.set_margin(20);
    this->m_btn1.signal_clicked().connect(sigc::bind(
                sigc::mem_fun(*this, &MainWindow::on_btn1_clicked), "Button 1"));
    this->m_box1.append(m_btn1);
    this->m_btn1.set_expand(false);
}

void MainWindow::on_btn1_clicked(const Glib::ustring& data) {
    auto dlg = Gtk::AlertDialog::create();
    dlg->set_message(data + " was clicked");
    dlg->set_detail("That was easy");
    dlg->set_buttons({});
    dlg->set_default_button(-1);
    dlg->set_cancel_button(-1);
    dlg->show(*this);
}

EOL

# MainWindow.h

touch ${Path}/${Name}/include/mainwindow.h 

cat > ${Path}/${Name}/include/mainwindow.h <<EOL
#ifndef __MAINWINDOW__
#define __MAINWINDOW__

#include <gtkmm.h>

class MainWindow : public Gtk::Window {
public:
    MainWindow();

protected:
    // Signals
    void on_btn1_clicked(const Glib::ustring& data);

    // Widgets
    Gtk::Box m_box1;
    Gtk::Button m_btn1;

private:
    void set_ui();
};

#endif

EOL
