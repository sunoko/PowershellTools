function Unregister-TaskRunner {
    Get-EventSubscriber | Unregister-Event
}