<?php

namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\Appointment;
use App\Models\Hospital;
use App\Models\Assign;
use Illuminate\Support\Facades\Log;

class HospitalController {
    public function RegisterLocation(Request $req){
        $location = new Hospital();
        $location->HospitalName = $req->HospitalName;
        $location->HospitalLang = $req->HospitalLang;
        $location->HospitalLong = $req->HospitalLong;
        $location->HospitalAddress = $req->HospitalAddress;
        
        $location->save();

        // Handle file upload
        if($req->hasFile('HospitalPict')) {
            $location->HospitalPicture = $req->file('HospitalPict')->move('hospital', $location->HospitalID.".".explode(".",$req->file('HospitalPict')->getClientOriginalName())[count(explode(".",$req->file('HospitalPict')->getClientOriginalName())) - 1]);;
        }
        
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

   public function ViewHospital($id) {
        return Hospital::where('hospital.HospitalID', $id)
            ->leftJoin('assign', 'assign.HospitalID', '=', 'hospital.HospitalID')
            ->leftJoin('doctor', 'doctor.DoctorID', '=', 'assign.DoctorID')
            ->leftJoin('appointment', 'appointment.AssignID', '=', 'assign.AssignID')
            ->selectRaw('
                hospital.*, 
                assign.*,
                doctor.*,
                COUNT(DISTINCT appointment.UserID) as "Total_Appointments",
                COUNT(DISTINCT CASE WHEN appointment.Ratings IS NOT NULL THEN appointment.UserID END) as "Total_Reviews",
                ROUND(AVG(appointment.Ratings), 1) as "Ratings"
            ')
            ->groupBy([
                'hospital.HospitalID',
                'hospital.HospitalName',
                'hospital.HospitalLang',
                'hospital.HospitalLong',
                'hospital.HospitalAddress',
                'doctor.DoctorID',
                'doctor.DoctorName',
                'doctor.DoctorPict',
                'doctor.DoctorEmail',
                'assign.AssignID' // Add other necessary columns from assign table
            ])
            ->first();
    }

    public function allHospital() {
        // Simplified approach: Get hospitals first, then add doctor data
        $hospitals = Hospital::get();
        $result = [];
        
        foreach ($hospitals as $hospital) {
            // Get the first assigned doctor for this hospital
            $assignment = Assign::where('HospitalID', $hospital->HospitalID)
                ->with('doctor')
                ->first();
            
            $hospitalData = $hospital->toArray();
            
            if ($assignment && $assignment->doctor) {
                $hospitalData['AssignID'] = $assignment->AssignID;
                $hospitalData['DoctorID'] = $assignment->doctor->DoctorID;
                $hospitalData['DoctorName'] = $assignment->doctor->DoctorName;
                $hospitalData['DoctorPict'] = $assignment->doctor->DoctorPict;
                $hospitalData['DoctorEmail'] = $assignment->doctor->DoctorEmail;
            } else {
                $hospitalData['AssignID'] = null;
                $hospitalData['DoctorID'] = null;
                $hospitalData['DoctorName'] = null;
                $hospitalData['DoctorPict'] = null;
                $hospitalData['DoctorEmail'] = null;
            }
            
            // Add appointment counts (simplified)
            $hospitalData['Total_Appointments'] = 0;
            $hospitalData['Total_Reviews'] = 0;
            $hospitalData['Ratings'] = 0;
            
            $result[] = $hospitalData;
        }
        
        // Debug: Log the first hospital data
        if (count($result) > 0) {
            $firstHospital = $result[0];
            Log::info('First hospital data:', $firstHospital);
            Log::info('DoctorName from first hospital: ' . ($firstHospital['DoctorName'] ?? 'NULL'));
        }
        
        return $result;
    }

    public function DeleteHospital($id) {
        if(Hospital::where("HospitalID",$id)->delete() && Assign::where("HospitalID",$id)->delete() && Appointment::where("HospitalID",$id)->delete()){
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
        Hospital::where('LocationID',$req->LocationID)->update([
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

    public function allAppointment($id) {
        $assignIds = Assign::where("HospitalID", $id)->pluck('AssignID'); // Get all AssignIDs
        return Appointment::whereIn('AssignID', $assignIds)->get(); // Use whereIn for multiple IDs
    }

    public function selectAppointment($hostid, $id) {
        Log::info("selectAppointment called with hostid: $hostid, userid: $id");
        
        $ids = is_array($id) ? $id : [$id];
        
        // Get all assignments for this hospital
        $assignIds = Assign::where("HospitalID", $hostid)->pluck('AssignID');
        Log::info("Found assign IDs for hospital $hostid: " . $assignIds->toJson());
        
        // Get appointments for this user at this hospital
        $appointments = Appointment::whereIn('AssignID', $assignIds)
                            ->whereIn('UserID', $ids)
                            ->get();
        
        Log::info("Found appointments for user $id at hospital $hostid: " . $appointments->toJson());
        
        return $appointments;
    }
}
