#!/bin/bash

# This script will detect if you have drush installed or not
# and setup additional versions if one is already found
# At the end of this installer you will have drush versions
# 6 and 8 to your disposal that can be invoked by issuing
# drush6 or drush8 nstead of plain drush, and setup the aliases d6 and d8 
# This way if you have a 'regular drush' version installed you can still
# use that one by issuing drush as usual.

# Todo - make this accept version numbers as argv and do a case/shift on them
# so we can install any number of versions we want to :-)

# First get some info on available packages
# Store some results in vars & use to decide what actions to take
# Not adding php detection because if you use drush you should have
# that part ready to go.



function check_php_version {

  read -p "(c)ontinue or (a)bort? > " cy
  case $cy in
        [cC] ) printf "\nContinuing installation\n"
               ;;
        [aA] ) printf "\nAborting installation\n" && exit 1
               ;;
            *) printf "\nPlease enter c or a\n" && check_php_version
               ;;
  esac

}

function check_privs {

  if [ $(whoami) != 'root' ]; then
    printf "You should runs this script with elevation or as root user, not as $(whoami)\nQuitting...\n"
    exit 1
  fi
}

function get_ownership {

  # We need this to setup rights on the downloaded files/folders
  printf 'Please enter your regular user and group names in the following format:\n user:group\n'
  read ownership
  if [ -z $ownership ]; then
    printf "Nothing received..."
    get_ownership
  else
    #check if input makes sense by checking the homedirwith some bash-fu
    if [ $(uname) == 'Linux' ]; then
        os_family=Linux
        user_name=$(ls -l /home/$(printf $ownership | cut -d : -f1) | tail -1 | awk '{print $3}')
        owner_check=$(ls -l /home/$(printf $ownership | cut -d : -f1) | tail -1 | awk '{print $3,$4}' | sed 's# #:#')
        if [ "$owner_check" == "$ownership" ]; then
            printf 'Ownership looks ok, continuing...\n\n'
        else
            printf "Ownership looks off, i saw '$owner_check' when i tried to look in your homedir\nLet's try again\n"
            get_ownership
        fi
    elif [ $(uname) == 'Darwin' ]; then
        user_name=$(ls -l /Users/$(printf $ownership | cut -d : -f1) | tail -1 | awk '{print $3}')
        owner_check=$(ls -l /Users/$(printf $ownership | cut -d : -f1) | tail -1 | awk '{print $3,$4}' | sed 's# #:#')
        os_family=Darwin
        if [ "$owner_check" == "$ownership" ]; then
             printf 'Ownership looks ok, continuing...\n\n'
        else
            printf "Ownership looks off, i saw '$owner_check' when i tried to look in your homedir\nLet's try again\n"
            get_ownership             
        fi
    fi
  fi
}


function check_packages {
   printf 'Checking for dependecies\n'
  #We need git to clone the repo
  if [ $(which git) == '' ]; then
    printf '  Git was not found, installing...\n'
    apt-get update
    apt-get install git -y
  else
    printf '  Git present on system - OK\n'
  fi

  #We need composer to install the drush versions
  if [ $(which composer) == '' ]; then
    printf '\n%s' '  Composer was not found on your system, installing...'
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    ln -s /usr/local/bin/composer /usr/bin/composer
  else
    printf '  Composer present on system - OK\n'
  fi

  # Check if there is a drush version present
  if [ $(which drush) == '' ]; then
    drush_present=0
  else
    drush_present=1
    #If drush is present find out what version
    drush_version_present=$($(which drush) --version | cut -d ' ' -f3)
    #bonuspoints - find out if installed with apt & warn
    if [ $os_family == 'Linux' ]; then
      drush_source=$(dpkg -l | grep drush)
      if [ "$drush_source" != '' ]; then
        printf "\nYou seem to have drush version $drush_version_present installed with your packet manager.\n"
        printf "The versions included in your distibution's repositories are usually out of date quite a bit,\n"
        printf "Please choose to keep using it or install a more up-to-date version.\n"
        printf "If you are not sure please opt to keep your version installed, or do some research and run this installer again.\n\n"
        read -p "Would you like to keep (1) or remove drush version $drush_version_present (2)? (press ctrl+c or x to abort this intaller) " ans
        while true ; do
          case "$ans" in
                 1) printf "Keeping drush $drush_version_present\n"; break ;;
  	             2) printf "Removing drush $drush_version_present\n"
                    apt-get remove drush; $drush_version_present=0; break
                    ;;
                 x) exit 
                    ;;
  	             *) printf "Please enter 1 or 2\n" && read ans 
                    ;;
          esac
        done
      fi
    fi
  fi
}


function install_drush_all {

      printf "\nInstalling drush 6.5.0\n\n"
      git clone https://github.com/drush-ops/drush.git /usr/local/src/drush6
      cd /usr/local/src/drush6
      chown -R $ownership /usr/local/src/drush6
      git checkout -b 6.5.0
      ln -s /usr/local/src/drush6/drush /usr/bin/drush6
      composer install
      # Drush 8
      printf "\nInstalling drush 8\n\n"
      git clone https://github.com/drush-ops/drush.git /usr/local/src/drush8
      cd /usr/local/src/drush8
      chown -R $ownership /usr/local/src/drush8
      git checkout master
      ln -s /usr/local/src/drush8/drush /usr/bin/drush8
      composer install
}

function install_drush_versions {
   printf "You have version $drush_version_present on your system, only installing extra versions\n"
   # Check if versions are not overlapping
   if [ $(printf $drush_version_present | cut -d . -f 1) != '6' ]; then
      # Drush 6
      printf "Installing drush 6.5.0\n"
      git clone https://github.com/drush-ops/drush.git /usr/local/src/drush6
      cd /usr/local/src/drush6
      chown -R $ownership /usr/local/src/drush6
      git checkout -b 6.5.0
      ln -s /usr/local/src/drush6/drush /usr/bin/drush6
      composer install
      if [ "$os_family" == 'Linux' ]; then
        alias_exists=$(grep drush6 /home/$user_name/.bashrc)
        if [ -z "alias_exists" ]; then
           printf "Alias for drush 6 not found in /home/$user_name/.bashrc\n"
           printf "alias d6='/usr/bin/drush6'" >> "/home/$user_name/.bashrc\n"
        fi
      fi
      if [ "$os_family" == 'Darwin' ]; then
        alias_exists=$(grep drush6 /Users/$user_name/.bash_profile)
        if [ -z "alias_exists" ]; then
           printf "Adding alias for drush 6 in /Users/$user_name/.bash_profile\n"
           printf "alias d6='/usr/bin/drush6'" >> "/Users/$user_name/.bash_profile\n"
        fi
      fi       
   fi
   if [ $(printf $drush_version_present | cut -d . -f 1) != '8' ]; then
      # Drush 8
      printf "Installing drush 8\n"
      git clone https://github.com/drush-ops/drush.git /usr/local/src/drush8
      cd /usr/local/src/drush8
      chown -R $ownership /usr/local/src/drush8
      git checkout master
      ln -s /usr/local/src/drush8/drush /usr/bin/drush8
      composer install
      if [ "$os_family" == 'Linux' ]; then
        if [ -z "$(grep drush8 /home/$user_name/.bashrc)" ]; then
           printf "Alias for drush 8 not found in /home/$user_name/.bashrc\n"
           printf "alias d8='/usr/bin/drush8'" >> "/home/$user_name/.bashrc\n"
        fi
      fi
      if [ "$os_family" == 'Darwin' ]; then
        if [ -z "$(grep drush8 /Users/$user_name/.bash_profile))" ]; then
           printf "Adding alias for drush 8 in /Users/$user_name/.bash_profile\n"
           printf "alias d8='/usr/bin/drush8'" >> "/Users/$user_name/.bash_profile\n"
        fi
      fi      
   fi
}



# Go!
check_privs
php_version=$(php --version | cut -d -  -f 1 | head -1 | cut -d ' ' -f 2 )
printf "These packages require php >=5.4.5\nYour PHP version is $php_version\nYou should abort this install if your version does not meet the minimun required version\n"
check_php_version
get_ownership
check_packages
 
if [ -z "$drush_present"  ]; then
   install_drush_all
else
   install_drush_versions
fi

cat<<EOF
-----------------------------------------------------------------------------------------------------------------------
|                                                                                                                     |
| All done, please check your path by runnin 'echo \$PATH' as your regular user, if /usr/bin is inthere all is good.  |
| Otherwise add                                                                                                       |
|                                                                                                                     |
|    PATH=/usr/bin/$PATH                                                                                              |
|                                                                                                                     |
| to your .bashrc file, or add /usr/bin to your ~/.profile if your system uses it.                                    |
|                                                                                                                     |
| To load the aliases just open an new terminal or run                                                                |
|                                                                                                                     |
|     source ~/.bashrc                                                                                                |
|                                                                                                                     |
| and continue working in this one. Once this is done you can use                                                     |
| 'drush6' or 'd6' to use drush 6                                                                                     |
| 'drush8' or 'd8' to use drush 8                                                                                     |
|                                                                                                                     |
| If you had a previous installation of drush it will be the one used when calling just 'drush'                       |
|                                                                                                                     |
| Happy drushing :-)                                                                                                  |
----------------------------------------------------------------------------------------------------------------------
EOF
