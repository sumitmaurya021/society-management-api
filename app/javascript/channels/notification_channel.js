import consumer from "./consumer";

let NotificationChannel;

document.addEventListener('turbolinks:load', () => {
  if (!NotificationChannel) {
    NotificationChannel = consumer.subscriptions.create("NotificationChannel", {
      connected() {
        console.log("Connected to the Notification Channel");
      },

      disconnected() {
        console.log("Disconnected from the Notification Channel");
      },

      received(data) {
        alert(`New Notification: ${data.title} - ${data.message}`);
      }
    });
  }
});

// Ensure proper unsubscribing logic, particularly with Turbolinks or similar
document.addEventListener('turbolinks:before-visit', () => {
  if (NotificationChannel) {
    consumer.subscriptions.remove(NotificationChannel);
    NotificationChannel = null;
    console.log("Unsubscribed from the Notification Channel");
  }
});
