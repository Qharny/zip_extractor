import 'lib/components/menu.dart';
import 'lib/components/extractor.dart';
import 'lib/components/help.dart';
import 'lib/components/about.dart';

void main(List<String> args) async {
  // Check for help flag
  if (args.contains('--help') || args.contains('-h')) {
    showHelp();
    return;
  }

  printWelcome();

  // Show main menu and get user choice
  final choice = await showMainMenu();

  switch (choice) {
    case '1':
      await runZipExtractor();
      break;
    case '2':
      showHelp();
      break;
    case '3':
      showAbout();
      break;
    case '4':
      print('👋 Thanks for using ZIP Extractor Tool!');
      return;
    default:
      print('❌ Invalid option. Exiting.');
      return;
  }
}
