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
        $users->UserEmail = $req->query('UserEmail');
        $users->UserPassword = hash("sha256", $req->query('UserPassword'));
        $users->UserName = $req->query('UserName');

        if($users->save()){
            return response()->json([
                'status' => 200,
                'data' => "Data Inserted Successfully"
            ]);
        }

        return response()->json([
            'status' => 401,
            "error" => "Something wrong, Please Try Again"
        ]);
    }

    public function CheckUser(Request $req) {
        $user = Users::where("UserEmail", $req->query('UserEmail'))->first();
        
        if(!$user) {
            return response()->json([
                "status" => 402,
                "error" => "Not Authorized, Wrong Email" 
            ]);
        }

        if($user->UserPassword === hash("sha256", $req->query('UserPassword'))) {
            return response()->json([
                "status" => 200,
                "data" => $user
            ]);
        }

        return response()->json([
            "status" => 403,
            "error" => "Not Authorized, Wrong Password" 
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
        Users::where('UserID',$req->UserID)->update([
            'UserEmail' => $req -> UserEmail,
            'UserPassword' => $req -> hash("sha256",$req->UserPassword),
            'UserName' => $req->UserName,
        ]); 

        return ([
            "status" => 200,
            "data" => "Data updated successfully"
        ]);
    }
}
