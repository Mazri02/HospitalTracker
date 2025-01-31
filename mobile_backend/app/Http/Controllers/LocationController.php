<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\Location;
use Illuminate\Support\Facades\Log;

class LocationController {
    public function RegisterLocation(Request $req){
        Log::info($req);
        $location = new Location();
        $location->HospitalName = $req->HospitalName;
        $location->HospitalLang = $req->HospitalLang;;
        $location->HospitalLong =$req->HospitalLong;
        $location->HospitalAddress =$req->HospitalAddress;
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

    public function ViewAllLocation() {
        return Location::all();
    }

    public function ViewLocationByID(Request $req) {
        return Location::where('LocationID')->get();
    }

    public function DeleteLocation(Request $req) {
        Log::info($req);
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
        ]); 

        return ([
            "status" => 200,
            "data" => "Data updated successfully"
        ]);
    }
}
