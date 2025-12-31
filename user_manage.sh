#!/bin/bash

# Check if the script is run as root (using sudo)
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root (use sudo)"
    exit 1
fi

while true; do
    echo "================================="
    echo "User Management Script"
    echo "================================="
    echo "1. Create User"
    echo "2. Delete User"
    echo "3. Add User to Group"
    echo "4. Display Users and Groups"
    echo "5. Exit"
    echo "=============================="

    read -p "Enter your choice: " choice

    case $choice in
        1)
            # Create User
            while true; do
                read -p "Enter username to create: " username
                if [ -z "$username" ]; then
                    echo "Error: username cannot be empty"
                elif [[ ! "$username" =~ ^[a-zA-Z0-9]+$ ]]; then
                    echo "Invalid username: special characters/spaces and numbers are not allowed."
                    echo "Please enter a valid username."
                elif id "$username" &>/dev/null; then
                    echo "User '$username' already exists."
                    
                else 
                    if useradd -m "$username"; then
                        echo "Set password for the user '$username':"
                        passwd "$username"
                        echo "User '$username' created successfully."
                        break
                    else 
                        echo "Failed to add user '$username'."
                    fi
                fi
            done
            ;;
        
        2) 
            # Delete User
            read -p "Enter username to delete: " username
            if [ -z "$username" ]; then
                echo "Error: Input cannot be empty."
            elif ! id "$username" &>/dev/null; then
                echo "User '$username' does not exist."
            else
                if userdel -r "$username"; then 
                    echo "User '$username' deleted successfully."
                else
                    echo "Failed to delete user '$username'."
                fi
            fi
            ;;
        
        3)
            # Add User to Group
            read -p "Enter username: " username
            read -p "Enter groupname: " groupname
            if ! id "$username" &>/dev/null; then
                echo "Error: User '$username' does not exist."
            elif ! getent group "$groupname" &>/dev/null; then
                 groupadd "$groupname"
                 echo " group created successfully"
            fi
            if usermod -aG "$groupname" "$username"; then
                 echo "User '$username' added to group '$groupname' successfully."
            else
                 echo "Failed to add user '$username' to group '$groupname'."
                
            fi
            ;;
        
        4)
            # Display Users and Groups
            echo "========== MENU =========="
            echo "1. Show All Users"
            echo "2. Show Groups and Members"
            read -p "Select [1 or 2]: " display
            if [ "$display" == "1" ]; then
                echo "---- SYSTEM USERS ----"
                cut -d: -f1 /etc/passwd | sort
            elif [ "$display" == "2" ]; then
                echo "----- GROUP & MEMBERS -----"
                awk -F: '{ if ($3 >= 1000) print "Group: " $1 " | Members: " $4 }' /etc/group
            else
                echo "Invalid selection."
            fi
            ;;
        
        5)
            # Exit
            echo "Exiting..."
            exit 0
            ;;
        
        *)
            echo "Invalid choice."
            exit 0
            ;;
    esac
done

