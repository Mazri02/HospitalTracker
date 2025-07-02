<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Model;

class Hospital extends Model {
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $table = 'hospital';
    protected $primaryKey = 'HospitalID';
    public $incrementing = true;
    protected $fillable = [
        'HospitalName',
        'HospitalLang',
        'HospitalLong',
        'HospitalAddress',
        'HospitalPicture',
    ];
}
