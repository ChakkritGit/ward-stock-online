import 'package:flutter/material.dart';
import 'package:vending_standalone/src/constants/colors.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';
import 'package:vending_standalone/src/configs/routes.dart' as custom_route;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        text: 'รายงาน',
        isBottom: false,
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.topLeft,
        child: Container(
          color: Colors.white,
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          custom_route.Routes.reportCurrentDrug,
                        )
                      },
                      splashColor: ColorsTheme.primary.withValues(alpha: 0.3),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          color: ColorsTheme.primary,
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 36.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: const Text(
                        "รายงานยาคงเหลือ",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      minTileHeight: 80.0,
                      horizontalTitleGap: 25.0,
                      trailing: const Icon(
                        Icons.navigate_next,
                        size: 36.0,
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                      height: 0.0,
                      indent: 100.0,
                    ),
                    ListTile(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          custom_route.Routes.reportBelow,
                        )
                      },
                      splashColor: ColorsTheme.primary.withValues(alpha: 0.3),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          color: ColorsTheme
                              .primary,
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 36.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: const Text(
                        "รายงานยาที่ต้องเติม",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      minTileHeight: 80.0,
                      horizontalTitleGap: 25.0,
                      trailing: const Icon(
                        Icons.navigate_next,
                        size: 36.0,
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                      height: 0.0,
                      indent: 100.0,
                    ),
                    ListTile(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          custom_route.Routes.reportLogDispense,
                        )
                      },
                      splashColor: ColorsTheme.primary.withValues(alpha: 0.3),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          color: ColorsTheme
                              .primary,
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 36.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: const Text(
                        "รายงานการจ่ายยาย้อนหลัง",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      minTileHeight: 80.0,
                      horizontalTitleGap: 25.0,
                      trailing: const Icon(
                        Icons.navigate_next,
                        size: 36.0,
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                      height: 0.0,
                      indent: 100.0,
                    ),
                    ListTile(
                      onTap: () => {
                        Navigator.pushNamed(
                          context,
                          custom_route.Routes.reportPrePack,
                        )
                      },
                      splashColor: ColorsTheme.primary.withValues(alpha: 0.3),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          padding: const EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          color: ColorsTheme
                              .primary,
                          child: const Icon(
                            Icons.picture_as_pdf,
                            size: 36.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: const Text(
                        "รายงานการจ่ายยาไม่ระบุใบยา",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      minTileHeight: 80.0,
                      horizontalTitleGap: 25.0,
                      trailing: const Icon(
                        Icons.navigate_next,
                        size: 36.0,
                      ),
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Colors.grey[300],
                      height: 0.0,
                      indent: 100.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
