<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Doctor;
use App\Models\Assign;
use App\Models\Appointment;

class DoctorController
{
    public function LoginDoctor(Request $req) {
        $user = Doctor::where("DoctorEmail", strtolower($req->get('UserEmail')))->first();
        
        if(!$user) {
            return response()->json([
                "status" => 402,
                "error" => "Email not found" 
            ]);
        }

        if($user->DoctorPassword == hash("sha256", $req->get('UserPassword'))) {
            return response()->json([
                "status" => 200,
                "token" => $user->createToken('hospital-user')->plainTextToken,
                "data" => [
                    'UserID' => $user->DoctorID,
                    'UserName' => $user->DoctorName,
                    'UserEmail' => $user->DoctorEmail
                ]
            ]);
        }

        return response()->json([
            "status" => 403,
            "error" => hash("sha256", $req->get('UserPassword'))
        ]);
    }

    public function RegisterDoctor(Request $req) {
        $users = new Doctor();
        $users->DoctorEmail = strtolower($req->get('UserEmail'));
        $users->DoctorPassword = hash("sha256", $req->get('UserPassword'));
        $users->DoctorName = $req->get('UserName');
        $users->save();

        // Handle file upload
        if ($req->hasFile('DoctorPict')) {
            $users->DoctorPict = $req->file('DoctorPict')->move('doctor', $users->DoctorID.".".explode(".",$req->file('DoctorPict')->getClientOriginalName())[count(explode(".",$req->file('DoctorPict')->getClientOriginalName())) - 1]);
        }

        if($users->save()){
            return response()->json([
                'status' => 200,
                'message' => "Registration successful",
                'data' => [
                    'UserID' => $users->DoctorID,
                    'UserName' => $users->DoctorName,
                    'UserEmail' => $users->DoctorEmail,
                    'DoctorPict' => $users->DoctorPict ?? null
                ]
            ]);
        }

        return response()->json([
            'status' => 401,
            "error" => "Registration failed, please try again"
        ]);
    }

    public function assignHospital($id,$hostid){
        $assign = new Assign();
        $assign->DoctorID = $id;
        $assign->HospitalID = $hostid;
        $assign->save();

        return response()->json([
            'status' => 200,
            'message' => "Hospital assigned successfully",
        ]);
    }

    public function leaveHospital($id,$hostid){
        $assign = Assign::where("DoctorID", $id)
               ->where("HospitalID", $hostid)
               ->first();

        if ($assign) {
            Appointment::where("AssignID", $assign->AssignID)->delete();
            Assign::where("DoctorID",$id)->where("HospitalID",$hostid)->delete();
            if(Appointment::where("AssignID",$assign->AssignID)->delete()){
                return ([
                    "status" => 200, 
                    "data" => "Location Deleted Successfully"
                ]);
            }
        } else {
            return ([
                "status" => 401, 
                "data" => "Something wrong, Please Try Again"
            ]);
        }
    }

    public function updateAppointment($id,$status){
        $message = Appointment::where('AppoinmentID',$id)->update([
            'Status' => $status,
        ]);

        return ([
            "status" => 200, 
            "data" => $message
        ]);
    }
}
