<?php

namespace App\Http\Controllers;
use App\Models\Users;
use Illuminate\Http\Request;

class UserController {
    public function RegisterUser(Request $req) {
        $users = new Users();
        $users->UserEmail = $req->UserEmail;
        $users->UserPassword = hash("sha256",$req->UserPassword);
        $users->UserName =$req->UserName;

        if($users->save()){
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

    public function CheckUser(Request $req) {
        if(Users::where("UserEmail",$req->UserEmail)->get()) {
            if(Users::where("UserPassword",hash("sha256",$req->UserPassword))->get()){
                return ([
                    "status" => 200,
                    "data" => Users::where("UserPassword",hash("sha256",$req->UserPassword))->get()
                ]);
            }

            return ([
                "status" => 403,
                "error" => "Not Authorized, Wrong Password" 
            ]);
        }

        return ([
            "status" => 402,
            "error" => "Not Authorized, Wrong Email" 
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
