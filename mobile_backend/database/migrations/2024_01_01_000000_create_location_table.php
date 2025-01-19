<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('location', function (Blueprint $table) {
            $table->id('LocationID');
            $table->string('HospitalName');
            $table->string('HospitalAddress');
            $table->double('HospitalLang', 10, 6); // Latitude with 6 decimal places
            $table->double('HospitalLong', 10, 6); // Longitude with 6 decimal places
            $table->timestamps(); // Creates created_at and updated_at columns
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('location');
    }
}; 