// Web-specific utilities for landing page
import 'dart:html' as html;

void scrollToSection(String sectionId) {
  html.window.location.hash = sectionId;
}

void openAppStore() {
  html.window.open('https://apps.apple.com/app/roadside-assistance', '_blank');
}

void openPlayStore() {
  html.window.open('https://play.google.com/store/apps/details?id=com.ras.customer_app', '_blank');
}

