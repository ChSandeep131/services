import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Pre extends StatefulWidget {
  const Pre({super.key});

  @override
  State<Pre> createState() => _PreState();
}

late ValueNotifier app_files_mode;

class _PreState extends State<Pre> {
  final controller = ScrollController();
  int page = 0;
  bool hasMoreItems = true;
  bool isLoading = false;
  List studentOfferList = [];
  List statusStudentVoucher = [];
  Future? offers;
  bool allow = false;

  @override
  void initState() {
    super.initState();
    app_files_mode = ValueNotifier("");

    offers = fetch();
    fetch();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
    initializeStatusStudentVoucher(); // Initialize statusStudentVoucher
  }

  void initializeStatusStudentVoucher() {
    statusStudentVoucher.clear();
    for (int i = 0; i < studentOfferList.length; i++) {
      statusStudentVoucher
          .add(studentOfferList[i]['status'] == 1 ? true : false);
    }
    print("1234: ${statusStudentVoucher.length}");
  }

  Future fetch() async {
    if (isLoading) return;
    isLoading = true;
    const limit = 4;
    final response = await get(
      Uri.parse(
          "http://149.28.174.167/api/vouchers?categoryId=3fa85f64-5717-4562-b3fc-2c963f66afa6&merchantId=7e9de4d6-27e6-40d6-985a-c8047c1f822b&pageIndex=$page&pageSize=$limit&sortBy=id&sortOrder=DESC"),
      headers: {
        "accept": "*/*",
        "Content-Type": "application/json",
        "Authorization":
            "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1OGJmNDVkOS1kZTUyLTRmZDktYjI2NS1hMmUzMzE0NWM4OGEiLCJpYXQiOjE3MDAxMTMzNDAsImV4cCI6MTcwMDk3NzM0MH0.cQKR4ITpRucfMls9y0hnJft1NmyaG0z9Zboku9s6H_kPSXRDgeORIQ5f8hN0i1l3bVGcztzOOXZTBrVatCr0sg"
      },
    );
    if (response.statusCode == 200) {
      final Map mapresponse = json.decode(response.body);
      List newList = mapresponse['data'];
      setState(() {
        page++;
        isLoading = false;
        if (newList.length < limit) {
          hasMoreItems = false;
        }
        studentOfferList.addAll(newList);
      });

      initializeStatusStudentVoucher();
    }
  }

  Future update(
    String voucherId,
    String categoryId,
    int consumedCount,
    String description,
    int maxUsageCount,
    String merchantId,
    String name,
    bool restrictUsageForUser,
    int status,
    String validityEndDate,
    String validityStartDate,
    String voucherAssetId,
    String voucherCode,
    double voucherValue,
    String voucherValueType,
  ) async {
    var data = json.encode({
      "categoryId": categoryId,
      "consumedCount": consumedCount,
      "description": description,
      "maxUsageCount": maxUsageCount,
      "merchantId": merchantId,
      "name": name,
      "restrictUsageForUser": restrictUsageForUser,
      "status": status,
      "validityEndDate": validityEndDate,
      "validityStartDate": validityStartDate,
      "voucherAssetId": voucherAssetId,
      "voucherCode": voucherCode,
      "voucherValue": voucherValue,
      "voucherValueType": voucherValueType
    });
    http.Response response = await http.put(
      Uri.parse("http://149.28.174.167/api/vouchers/$voucherId"),
      headers: {
        "accept": "*/*",
        "Content-Type": "application/json",
        "Authorization":
            "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1OGJmNDVkOS1kZTUyLTRmZDktYjI2NS1hMmUzMzE0NWM4OGEiLCJpYXQiOjE3MDAxMTMzNDAsImV4cCI6MTcwMDk3NzM0MH0.cQKR4ITpRucfMls9y0hnJft1NmyaG0z9Zboku9s6H_kPSXRDgeORIQ5f8hN0i1l3bVGcztzOOXZTBrVatCr0sg"
      },
      body: data,
    );
    print(response.body);

    if (response.statusCode == 200) {
      print(response.statusCode);
      setState(() {
        Map updateVoucher = json.decode(response.body);
      });
    }
  }

  Future refresh() async {
    setState(() {
      isLoading = false;
      hasMoreItems = true;
      page = 0;
      studentOfferList.clear();
    });
    await fetch(); // Fetch new data after resetting the state
  }

  @override
  Widget build(BuildContext context) {
    final screensize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagination"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: RefreshIndicator(
            onRefresh: refresh,
            child: studentOfferList.isEmpty &&
                    isLoading // Check if no data and still loading
                ? const Center(
                    child:
                        CircularProgressIndicator(), // Show a loading indicator
                  )
                : studentOfferList.isEmpty
                    ? Container(
                        height: (MediaQuery.of(context).size.height),
                        color: Colors.white,
                        child: const Center(
                          child: Text("No Voucher available"),
                        ),
                      )
                    : ListView.builder(
                        itemCount: studentOfferList == null
                            ? 0
                            : studentOfferList.length + 1,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: controller,
                        itemBuilder: (context, index) {
                          if (index < studentOfferList.length) {
                            return Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  10.0, 10.0, 10.0, 10.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /////// network image and Tap to flip Deatils //////
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            7.0, 7.0, 7.0, 7.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Stack(
                                              alignment:
                                                  const AlignmentDirectional(
                                                      0.0, 1.0),
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                  child: ValueListenableBuilder(
                                                    valueListenable:
                                                        app_files_mode,
                                                    builder: (context, value,
                                                        child) {
                                                      return Image.network(
                                                        app_files_mode.value
                                                                    .toString() ==
                                                                ""
                                                            ? '${studentOfferList[index]["voucherAsset"]["filePath"]}&folderName=${studentOfferList[index]["voucherAsset"]["folderName"]}'
                                                            : '${studentOfferList[index]["voucherAsset"]["filePath"]}',
                                                        height: 230.0,
                                                        fit: BoxFit.fill,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 50.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              Color(0x33FFFFFF),
                                                          offset:
                                                              Offset(1.0, 0.0),
                                                          spreadRadius: 0.0,
                                                        )
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                12.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                12.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                0.0),
                                                        topRight:
                                                            Radius.circular(
                                                                0.0),
                                                      ),
                                                    ),
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .flip_camera_android,
                                                          size: 20.0,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        5.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            child: Text(
                                                              'Tap to Flip',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: allow
                                                      ? studentOfferList[index][
                                                                      "restrictUsageForUser"] ==
                                                                  true &&
                                                              studentOfferList[
                                                                          index]
                                                                      [
                                                                      "voucherUsageLogs"]
                                                                  .isNotEmpty
                                                          ? Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 230.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: const Color(
                                                                    0x5A000000),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        125.0,
                                                                    height:
                                                                        40.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                          0x5AFFFFFF),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    child:
                                                                        const Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .thumb_up_outlined,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        Text(
                                                                          'Redeemed',
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : Container()
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Status",
                                        ),
                                        Switch(
                                          value: statusStudentVoucher[index],
                                          onChanged: (value) {
                                            setState(() {
                                              statusStudentVoucher[index] =
                                                  value;
                                            });
                                            update(
                                                studentOfferList[index]['id'],
                                                studentOfferList[index]
                                                    ['categoryId'],
                                                studentOfferList[index]
                                                    ["consumedCount"],
                                                studentOfferList[index]
                                                    ['description'],
                                                studentOfferList[index]
                                                    ["maxUsageCount"],
                                                studentOfferList[index]
                                                    ["merchantId"],
                                                studentOfferList[index]["name"],
                                                studentOfferList[index]
                                                    ["restrictUsageForUser"],
                                                statusStudentVoucher[index] ==
                                                        true
                                                    ? 1
                                                    : 0,
                                                studentOfferList[index]
                                                    ["validityEndDate"],
                                                studentOfferList[index]
                                                    ["validityStartDate"],
                                                studentOfferList[index]
                                                    ["voucherAssetId"],
                                                studentOfferList[index]
                                                    ["voucherCode"],
                                                studentOfferList[index]
                                                    ["voucherValue"],
                                                studentOfferList[index]
                                                    ["voucherValueType"]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  ////// Item name and Money details //////
                                  ////// The kauphy Place and update voucher details ////
                                ],
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: hasMoreItems
                                    ? const CircularProgressIndicator()
                                    : Container(),
                              ),
                            );
                          }
                        },
                      )),
      ),
    );
  }
}
