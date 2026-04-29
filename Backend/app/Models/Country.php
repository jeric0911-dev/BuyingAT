<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Country extends Model
{
    use HasFactory;

    protected $fillable = ['status', 'country_name', 'iso_code', 'phone_code'];

    //get cities by country
    public function cities()
    {
        return $this->hasMany(City::class, 'country_id');
    }

    public function states()
    {
        return $this->hasMany(State::class);
    }
}
