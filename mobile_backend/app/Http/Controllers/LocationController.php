<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\Location;

class LocationController {
    public function RegisterLocation(Request $req){
        $location = new Location();
        $location->HospitalName = $req->HospitalName;
        $location->HospitalLang = $req->HospitalLang;;
        $location->HospitalLong =$req->HospitalLong;
        $location->HospitalAddress =$req->HospitalAddress;
        $location->UserID =$req->UserID;
        if($location->save()){
            return ([
                'status' => 200,
                'data' => "Data Inserted Successfully"
            ]);
        }

        return ([
            'status' => 401,
            "error" => "Something wrong, Please Try Again"
        ]);
    }

    public function ViewAllLocation(Request $req) {
        return Location::all();
    }

    public function ViewLocationByID(Request $req) {
        return Location::where('LocationID')->get();
    }

    public function DeleteLocation(Request $req) {
        if(Location::where("LocationID",$req->LocationID)->delete()){
            return ([
                "status" => 200, 
                "data" => "Location Deleted Successfully"
            ]);
        }

        return ([
            "status" => 401, 
            "data" => "Something wrong, Please Try Again"
        ]);
    }

    public function updateLocation(Request $req){
        Location::where('LocationID',$req->LocationID)->update([
            'HospitalName' => $req->HospitalName,
            'HospitalLang' => $req->HospitalLang,
            'HospitalLong' => $req->HospitalLong,
            'HospitalAddress' => $req->HospitalAddress,
            'UserID' => $req->UserID
        ]); 

        return ([
            "status" => 200,
            "data" => "Data updated successfully"
        ]);
    }
}
