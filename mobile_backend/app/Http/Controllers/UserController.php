<?php

namespace App\Http\Controllers;
use App\Models\Users;
use App\Models\Doctor;
use App\Models\Assign;
use App\Models\Appointment;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class UserController {
    public function RegisterUser(Request $req) {
        $users = new Users();
        $users->UserEmail = strtolower($req->get('UserEmail'));
        $users->UserPassword = hash("sha256", $req->get('UserPassword'));
        $users->UserName = $req->get('UserName');

        if($users->save()){
            return response()->json([
                'status' => 200,
                'message' => "Registration successful",
                'data' => [
                    'UserID' => $users->UserID,
                    'UserName' => $users->UserName,
                    'UserEmail' => $users->UserEmail
                ]
            ]);
        }

        return response()->json([
            'status' => 401,
            "error" => "Registration failed, please try again"
        ]);
    }

    public function LoginUser(Request $req) {
        $user = Users::where("UserEmail", strtolower($req->get('UserEmail')))->first();
        
        if(!$user) {
            return response()->json([
                "status" => 402,
                "error" => "Email not found" 
            ]);
        }

        if($user->UserPassword === hash("sha256", $req->get('UserPassword'))) {
            return response()->json([
                "status" => 200,
                "token" => $user->createToken('hospital-user')->plainTextToken,
                "data" => [
                    'UserID' => $user->UserID,
                    'UserName' => $user->UserName,
                    'UserEmail' => $user->UserEmail
                ]
            ]);
        }

        return response()->json([
            "status" => 403,
            "error" => "Invalid password" 
        ]);
    }
    
    public function DeleteUser($id, $type) {
        DB::beginTransaction();
        
        try {
            if($type == "doctor") {
                $hospitalPath = Doctor::where('DoctorID', $id)->first()->HospitalPict;
                unlink($hospitalPath);

                $assignIds = Assign::where('DoctorID', $id)->pluck('AssignID');
                Appointment::whereIn('AssignID', $assignIds)->delete();
                Assign::where('DoctorID', $id)->delete();
                
                if(!Doctor::where('DoctorID',$id)->delete()) {
                    throw new \Exception("Failed to delete doctor");
                }
            } else if($type == "user") {
                Appointment::where('UserID', $id)->delete();
                
                if(!Users::where('UserID',$id)->delete()) {
                    throw new \Exception("Failed to delete user");
                }
            }
            
            DB::commit();
            
            return response()->json([
                "status" => 200,
                "data" => "Data deleted successfully"
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                "status" => 401,
                "data" => "Something is Wrong, Please Try Again",
                "error" => $e->getMessage()
            ], 401);
        }
    }

    public function EditUser($id, $type, Request $req) {
        try {
            $updateData = [];
            
            // Common fields
            $emailField = $type == "doctor" ? 'DoctorEmail' : 'UserEmail';
            $nameField = $type == "doctor" ? 'DoctorName' : 'UserName';
            $passwordField = $type == "doctor" ? 'DoctorPassword' : 'UserPassword';
            
            $updateData = [
                $emailField => $req->UserEmail,
                $nameField => $req->UserName,
            ];

            // Handle password update
            if ($req->has('UserPassword')) {
                $updateData[$passwordField] = hash("sha256", $req->UserPassword);
            }

            // Handle image upload (only for doctors)
            if ($type == "doctor" && $req->hasFile('DoctorPict')) {
                $doctor = Doctor::where('DoctorID', $id)->first();
                
                // Delete old image if exists
                if ($doctor->DoctorPict && file_exists(public_path($doctor->DoctorPict))) {
                    unlink(public_path($doctor->DoctorPict));
                }

                // Upload new image
                $file = $req->file('DoctorPict');
                $extension = $file->getClientOriginalExtension();
                $filename = $id . '.' . $extension;
                $path = 'doctor/' . $filename;
                
                // Create directory if it doesn't exist
                if (!file_exists(public_path('doctor'))) {
                    mkdir(public_path('doctor'), 0755, true);
                }
                
                $file->move(public_path('doctor'), $filename);
                $updateData['DoctorPict'] = $path;
            }

            // Update the appropriate model
            $model = $type == "doctor" ? Doctor::class : Users::class;
            $model::where($type == "doctor" ? 'DoctorID' : 'UserID', $id)->update($updateData);

            return response()->json([
                "status" => 200,
                "message" => "User updated successfully",
                "data" => $updateData
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "status" => 500,
                "error" => "Server error: " . $e->getMessage(),
                "trace" => $e->getTrace() // Remove this in production
            ], 500);
        }
    }
    public function GetUserData($id,$type) {
        try {
            if (!$id) {
                return response()->json([
                    "status" => 400,
                    "error" => "UserID is required"
                ]);
            }

            $user = ($type == 'doctor')? Doctor::where("DoctorID", $id)->first() : Users::where("UserID", $id)->first();
            
            if(!$user) {
                return response()->json([
                    "status" => 404,
                    "error" => "User not found"
                ]);
            }

            if($type == "doctor") {
                return response()->json([
                    "status" => 200,
                    "data" => [
                        'UserID' => $user->DoctorID,
                        'UserName' => $user->DoctorName,
                        'UserEmail' => $user->DoctorEmail,
                        'UserPassword' => $user->DoctorPassword,
                        'DoctorPict' => $user->DoctorPict
                    ]
                ]);   
            } else {
                return response()->json([
                    "status" => 200,
                    "data" => [
                        'UserID' => $user->UserID,
                        'UserName' => $user->UserName,
                        'UserEmail' => $user->UserEmail
                    ]
                ]);
            }
        } catch (\Exception $e) {
            Log::error('GetUserData error: ' . $e->getMessage());
            return response()->json([
                "status" => 500,
                "error" => "Server error: " . $e->getMessage()
            ]);
        }
    }

    public function logout($id){
        if(Doctor::find($id)){
            Doctor::find($id)->tokens()->delete();
            return ([
                "status" => 200,
                "data" => "Logout Successfully"
            ]);
        } else if(Users::find($id)){
            Users::find($id)->tokens()->delete();
            return ([
                "status" => 200,
                "data" => "Logout Successfully"
            ]);
        }
    }

    public function bookAppointment($id,$assignid,Request $req){
        $appoint = new Appointment();
        $appoint->UserID = $id;
        $appoint->AssignID = $assignid;
        $appoint->Status = "Pending";
        $appoint->AssignDate = $req->timeAppoint;
        $appoint->ReasonVisit = $req->reasonAppoint;

        if($appoint->save()){
            return response()->json([
                'status' => 200,
                'message' => "Appointment successful"
            ]);
        }

        return response()->json([
            'status' => 401,
            "error" => "Appointment failed, please try again"
        ]);
    }

    public function cancelAppointment($appointid){
        $appoint = Appointment::where('AppoinmentID',$appointid)->first();
        if($appoint->delete()){
            return response()->json([
                'status' => 200,
                'message' => "Appointment canceled"
            ]);
        }
    }

    public function submitReview($id, Request $req){
        return Appointment::where('AppoinmentID',$id)->update([
            'Reviews' => $req->reviews,
            'Ratings' => $req->ratings
        ]);
    }

    public function deleteReview($id){
        return Appointment::where('AppoinmentID',$id)->update([
            'Reviews' => null,
            'Ratings' => null
        ]);
    }
}
