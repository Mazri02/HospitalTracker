import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend/widget/yes_no_dialog.dart';
// import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'dart:convert';

class MapsForm extends StatefulWidget {
  final double? hospitalLang;
  final double? hospitalLong;
  final int? hospitalID;
  final String? hospitalAddress;
  final String? hospitalName;
  final bool? edit;
  const MapsForm(
      {Key? key,
      this.hospitalID,
      this.hospitalLang,
      this.hospitalLong,
      this.hospitalAddress,
      this.hospitalName,
      this.edit})
      : super(key: key);

  @override
  State<MapsForm> createState() => MapsFormState();
}

class MapsFormState extends State<MapsForm> {
  late LatLng _center = LatLng(0, 0); // London coordinates
  List<Marker> _markers = [];
  late final TextEditingController LocationController = TextEditingController();
  late final TextEditingController NameController = TextEditingController();
  final MapController _mapController = MapController();
  late final ipAddress = 'http://192.168.1.165:8000';

  Future<void> fetchLocation(String query) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (!data.isEmpty) {
        setState(() {
          _center = LatLng(
              double.parse(data[0]["lat"]), double.parse(data[0]["lon"]));
          LocationController.text = data[0]["display_name"];
          _mapController.move(_center, 16.0);

          _markers.clear();
          _markers.add(Marker(
              width: 80.0,
              height: 80.0,
              point: _center,
              builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  )));

          print(_center);
        });
      }
    }
  }

  void DeleteInformation() async {
    late final tokenDelete;
    final display = await getDisplayName(_center);
    final csrf = await http.get(Uri.parse(ipAddress + '/csrf-token'));
    if (csrf.statusCode == 200) {
      final data = json.decode(csrf.body);
      tokenDelete = data['csrf_token'];
    } else {
      throw Exception('Failed to load CSRF token');
    }

    final res =
        await http.post(Uri.parse(ipAddress + '/api/DeleteLocation'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'X-CSRF-TOKEN': tokenDelete,
            },
            body: jsonEncode({'LocationID': widget.hospitalID}));

    if (res.statusCode == 200) {
      showYesNoDialog(
        context: context,
        title: "Location has been deleted",
        message:
            "The selected location has been deleted, Please Return to the Home Page",
        positiveButton: "Close",
      );
    } else {
      print("Status Code: ${res.statusCode}");
      // print("Response Body: ${res.body}");
      print("Headers: ${res.headers}");
      print("Body: ${res.body}");
      print("Request URL: ${res.request?.url}");
      print("Something wrong, Please Try Again");
    }
  }

  Future<String> getDisplayName(LatLng point) async {
    final String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('display_name')) {
          print(data['display_name']);
          return data['display_name'];
        } else {
          return 'Unknown location';
        }
      } else {
        return 'Error: Unable to fetch data';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  void TapLocation(LatLng point) async {
    LocationController.text = await getDisplayName(point);
    setState(() {
      _center = point;
      _mapController.move(_center, 16.0);
      _markers.clear();
      _markers.add(Marker(
          width: 80.0,
          height: 80.0,
          point: _center,
          builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              )));

      print(_center);
    });
  }

  void StoreInformation() async {
    late final tokenStore;
    final display = await getDisplayName(_center);
    final csrf = await http.get(Uri.parse(ipAddress + '/csrf-token'));
    if (csrf.statusCode == 200) {
      final data = json.decode(csrf.body);
      tokenStore = data['csrf_token'];
    } else {
      throw Exception('Failed to load CSRF token');
    }

    final res =
        await http.post(Uri.parse(ipAddress + '/api/RegisterLocation'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'X-CSRF-TOKEN': tokenStore,
            },
            body: jsonEncode({
              'HospitalLang': _center.latitude,
              'HospitalLong': _center.longitude,
              'HospitalAddress': display,
              'HospitalName': NameController.text,
            }));

    if (res.statusCode == 200) {
      showYesNoDialog(
        context: context,
        title: "Location has been sent",
        message:
            "The specified location has been marked on the map, Thank You for your Contribution.",
        positiveButton: "Close",
      );
    } else {
      print("Status Code: ${res.statusCode}");
      print("Response Body: ${res.body}");
      print("Headers: ${res.headers}");
      print("Request URL: ${res.request?.url}");
      print("Something wrong, Please Try Again");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.edit == false) {
      _center = LatLng(widget.hospitalLang!, widget.hospitalLong!);
      LocationController.text = widget.hospitalAddress!;
      NameController.text = widget.hospitalName!;

      _markers.add(Marker(
          width: 80.0,
          height: 80.0,
          point: _center,
          builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        title: Text(
          'Insert Hospital Location',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      center: _center,
                      zoom: 16.0,
                      onTap: (tapPosition, point) {
                        TapLocation(point);
                        print(tapPosition);
                      }),
                  children: [
                    TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app'),
                    MarkerLayer(
                      markers: _markers,
                    )
                  ],
                ),
              ),
              Container(
                  child: FormField(
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextField(
                          enabled: widget.edit,
                          controller: LocationController,
                          decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    fetchLocation(LocationController.text);
                                  },
                                  child: Icon(Icons.search)),
                              labelText: "Hospital Location"),
                          onChanged: (value) {
                            state.didChange(value);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextField(
                          controller: NameController,
                          enabled: widget.edit,
                          decoration:
                              InputDecoration(labelText: "Hospital Name"),
                          onChanged: (value) {
                            state.didChange(value);
                          },
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: widget.edit!
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Text("Submit"),
                                    onPressed: () {
                                      StoreInformation();
                                    },
                                  )
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Text("Delete Location"),
                                    onPressed: () {
                                      DeleteInformation();
                                    },
                                  ),
                          )),
                    ],
                  );
                },
                validator: (value) {
                  return value != null ? 'This field is required' : null;
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
