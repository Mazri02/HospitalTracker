<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Doctor extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'doctor';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'DoctorID';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'DoctorEmail',
        'DoctorPassword',
        'DoctorName',
        'DoctorPict',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Get the password for the doctor.
     *
     * @return string
     */
    public function getAuthPassword()
    {
        return $this->DoctorPassword;
    }

    /**
     * Get the assignments for this doctor.
     */
    public function assignments()
    {
        return $this->hasMany(Assign::class, 'DoctorID', 'DoctorID');
    }
}