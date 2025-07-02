<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Assign extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'assign';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'AssignID';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'HospitalID',
        'DoctorID',
    ];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * Get the hospital associated with this assignment.
     */
    public function hospital()
    {
        return $this->belongsTo(Hospital::class, 'HospitalID', 'HospitalID');
    }

    /**
     * Get the doctor associated with this assignment.
     */
    public function doctor()
    {
        return $this->belongsTo(Doctor::class, 'DoctorID', 'DoctorID');
    }

    /**
     * Get the appointments for this assignment.
     */
    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'AssignID', 'AssignID');
    }
}