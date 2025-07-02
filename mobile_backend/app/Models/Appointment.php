<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Appointment extends Model
{
    use HasFactory;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'appointment';

    /**
     * The primary key for the model.
     *
     * @var string
     */
    protected $primaryKey = 'AppoinmentID';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'UserID',
        'AssignID',
        'Reviews',
        'Ratings',
        'Status',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'Ratings' => 'integer',
    ];

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * Get the user associated with the appointment.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'UserID', 'UserID');
    }

    /**
     * Get the assign record associated with the appointment.
     */
    public function assign()
    {
        return $this->belongsTo(Assign::class, 'AssignID', 'AssignID');
    }
}