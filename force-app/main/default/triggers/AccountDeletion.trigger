trigger AccountDeletion on Account (before insert) {
AccountHandler.insertAccount(Trigger.new);

}