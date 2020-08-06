

handle_container_error() {
result=$?
if [ $result -ne 0 ]
then
    echo
    echo "Hint: If you're told the 'container is not running' you'll need to start it first:"
    echo
    echo "    % docker-compose up -d website"
    exit $result
fi
}