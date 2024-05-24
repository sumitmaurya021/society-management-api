import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    console.log("Connected to the Notification Channel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    alert(`New Notification: ${data.title} - ${data.message}`);
  }
});
