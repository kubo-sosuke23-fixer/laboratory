terraform {
  # バックエンド情報は下記のいずれかによって与える。
  # - コマンド実行時のオプション -backend-config で与える。
  # - override.tf にバックエンド情報を記載し、plan/apply実行時に上書きされるようにする。
  backend "azurerm" {}
}
