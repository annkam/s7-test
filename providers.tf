provider "google" {
  credentials = "${file("credentials.json")}"
  project     = "stellar-concord-224314"
  region      = "us-central1"
  zone        = "us-central1-c"
}
