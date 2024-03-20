#!/bin/bash

# Function to display docker services to debug and ask user for selection using gum choose
select_service_to_debug() {
    # Get list of services
    services=$(docker service ls --format "{{.Name}} {{.Replicas}}" | grep 0/ | awk '{print $1}')

    # Check if there are any services
    if [ -z "$services" ]; then
        echo "No services found."
        exit 1
    fi

    # Use gum choose to select a service
    selected_service=$(echo "$services" | gum choose)

    # Return selected service
    echo "$selected_service"
}

# Function to display docker services to view logs and ask user for selection using gum choose
select_service() {
    # Get list of services
    services=$(docker service ls --format "{{.Name}}")

    # Check if there are any services
    if [ -z "$services" ]; then
        echo "No services found."
        exit 1
    fi

    # Use gum choose to select a service
    selected_service=$(echo "$services" | gum choose)

    # Return selected service
    echo "$selected_service"
}

# Function to display docker containers and ask user to choose a container using gum choose
select_container() {
    # Get list of containers
    containers=$(docker container ls --format "{{.Name}}")

    # Check if there are any containers
    if [ -z "$containers" ]; then
        echo "No containers found."
        exit 1
    fi

    # Use gum choose to select a container
    selected_container=$(echo "$containers" | gum choose)

    # Return selected container
    echo "$selected_container"
}

# Function to check logs of all docker services
check_logs() {
    while true; do
        # Select a service
        selected_service=$(select_service)

        # Check if service name is provided
        if [ -z "$selected_service" ]; then
            echo "No service selected. Exiting..."
            exit 1
        fi

        # Check logs, last 50 lines
        docker service logs -n 50 "$selected_service"

        # Prompt user to check logs of another service
        gum confirm "Do you want to check logs of another service?"
        if [ $? -ne 0 ]; then
            echo "Exiting..."
            exit 0
        fi
    done
}

# Function to take tcp dum of the selected service
tcp_dump() {
    while true; do
        # Select a container
        selected_container=$(select_container)

        # Check if container name is provided
        if [ -z "$selected_container" ]; then
            echo "No container selected. Exiting..."
            exit 1
        fi

        # Command to take tcp dump of the selected docker container
        sudo docker run --tty --net=container:"$selected_container" tcpdump tcpdump -N -A

        # Prompt user to take tcp dump of another container
        gum confirm "Do you want to check tcp dump of another container?"
        if [ $? -ne 0 ]; then
            echo "Exiting..."
            exit 0
        fi
    done
}

# Debug function to debug docker services that has not started
debug_services() {
    while true; do
        # Select a service
        selected_service=$(select_service_to_debug)

        # Check if the service name is provided
        if [ -z "$selected_service" ]; then
            echo "No service selected. Exiting..."
            exit 1
        fi

        # Prompt user to confirm execution of 'docker service ps --no-trunc' command
        gum confirm "Do you want to execute 'docker service ps --no-trunc' for service '$selected_service'?" && docker service ps --no-trunc "$selected_service"

        # Prompt user to confirm execution of 'docker service logs -f' command
        gum confirm "Do you want to execute 'docker service logs -n 50' for service '$selected_service'?" && docker service logs -n 50 "$selected_service"

        # Prompt user to debug another service
        gum confirm "Do you want to debug another service?"
        if [ $? -ne 0 ]; then
            echo "Exiting..."
            exit 0
        fi
    done
}

# Main function to execute commands
main() {
    gum style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        'Docker service debugger' 'First select an option to debug or to check logs!' 'Then one can continue to debug services or checking logs...'

    # Prompt user to select action
    action=$(gum choose "Select an action:" "Debug" "Check logs" "Tcp Dump")
    echo "$action"

    # Check if the action is Debug or Check logs
    if [[ "$action" == "Debug" ]]; then
        debug_services
    elif [[ "$action" == "Check logs" ]]; then
        check_logs
    elif  [[ "$action" == "Tcp Dump" ]]; then
        tcp_dump
    else
        echo "Invalid action..."
    fi
}

# Execute main function
main

