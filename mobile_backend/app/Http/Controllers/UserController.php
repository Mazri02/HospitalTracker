<?php

namespace App\Http\Controllers;
use App\Models\Users;
use Illuminate\Http\Request;

class UserController {
    public function RegisterUser(Request $req) {
        $req->validate([
            'UserEmail' => 'required|email|unique:users',
            'UserPassword' => 'required|min:6',
            'UserName' => 'required',
        ]);

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

    public function CheckUser(Request $req) {
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
                "message" => "Login successful",
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
    
    public function DeleteUser(Request $req) {
        if(Users::where('UserID',$req->UserID)->delete()) {
            return ([
                "status" => 200,
                "data" => "Data deleted Successfully"
            ]);
        }

        return ([
            "status" => 401,
            "data" => "Something is Wrong, Please Try Again"
        ]);
    }

    public function EditUser(Request $req) {
        try {
            $updateData = [
                'UserEmail' => $req->UserEmail,
                'UserName' => $req->UserName,
            ];

            // Only update password if it's provided
            if ($req->has('UserPassword')) {
                $updateData['UserPassword'] = hash("sha256", $req->UserPassword);
            }

            Users::where('UserID', $req->UserID)->update($updateData);

            return response()->json([
                "status" => 200,
                "data" => "Data updated successfully"
            ]);
        } catch (\Exception $e) {
            return response()->json([
                "status" => 500,
                "error" => "Server error: " . $e->getMessage()
            ]);
        }
    }

    public function GetUserData(Request $req) {
        try {
            $userId = $req->get('UserID');
            
            if (!$userId) {
                return response()->json([
                    "status" => 400,
                    "error" => "UserID is required"
                ]);
            }

            $user = Users::where("UserID", $userId)->first();
            
            if(!$user) {
                return response()->json([
                    "status" => 404,
                    "error" => "User not found"
                ]);
            }

            return response()->json([
                "status" => 200,
                "data" => [
                    'UserID' => $user->UserID,
                    'UserName' => $user->UserName,
                    'UserEmail' => $user->UserEmail
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('GetUserData error: ' . $e->getMessage());
            return response()->json([
                "status" => 500,
                "error" => "Server error: " . $e->getMessage()
            ]);
        }
    }
}
