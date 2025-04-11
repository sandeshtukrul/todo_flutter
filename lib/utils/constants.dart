import 'package:flutter/material.dart';
import 'package:ftoast/ftoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:todo/main.dart';
import 'package:todo/utils/app_str.dart';

/// lottie asset address
String lottieURL = 'assets/lottie/1.json';

/// avatar asset address
String avatarURL = 'assets/img/avatar.png';

/// Empty Titile Or Subtitle textField warning
void emptyWarning(BuildContext context) {
  FToast.toast(
    context,
    msg: AppStr.oopsMsg,
    subMsg: AppStr.emptyWarning,
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}

/// Nothing entered when user try to edit or update the current task
void updateTaskWarning(BuildContext context) {
  FToast.toast(
    context,
    msg: AppStr.oopsMsg,
    subMsg: AppStr.updateTaskWarning,
    corner: 20.0,
    duration: 3000,
    padding: const EdgeInsets.all(20),
  );
}

/// No Task warning dialog for deleting
Future<void> noTaskWarning(BuildContext context) {
  return PanaraInfoDialog.showAnimatedGrow(
    context,
    title: AppStr.oopsMsg,
    message: AppStr.noTaskWarning,
    buttonText: AppStr.understood,
    onTapDismiss: () {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.warning,
  );
}

/// Delete all task from DB Dialog
Future<bool> deleteAllTask(BuildContext context) async {
  bool confirmed = false;

  await PanaraConfirmDialog.show(
    context,
    title: AppStr.areYouSure,
    message: AppStr.deleteAllTask,
    confirmButtonText: AppStr.yes,
    cancelButtonText: AppStr.no,
    onTapConfirm: () {
      /// Delete All Task
      BaseWidget.of(context).dataStore.box.clear();
      confirmed = true;
      Navigator.pop(context);
    },
    onTapCancel: () {
      Navigator.pop(context);
    },
    panaraDialogType: PanaraDialogType.error,
    barrierDismissible: false,
  );

  return confirmed;
}
