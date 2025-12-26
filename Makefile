gen:
	flutter pub run build_runner build --delete-conflicting-outputs

gen-icon:
	flutter pub run flutter_launcher_icons:main
.PHONY: gen gen-icon build
build:
	flutter build apk --no-tree-shake-icons
build-bundle:
	flutter build appbundle --no-tree-shake-icons
