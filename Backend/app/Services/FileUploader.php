<?php

namespace App\Utils;

class FileUploader
{
    // Upload a single file with a custom name
    public static function uploadSingleFile(Request $request, $fileField, $directory = 'uploads', $disk = 'public')
    {
        if ($request->hasFile($fileField)) {
            $originalName = $request->file($fileField)->getClientOriginalName();

            $customFileName = 'Classified' . '_' . time() . '_' . pathinfo($originalName, PATHINFO_FILENAME) . '.' . $request->file($fileField)->getClientOriginalExtension();

            return $request->file($fileField)->storeAs($directory, $customFileName, $disk);
        }

        return null;
    }

    // Upload multiple files with custom names
    public static function uploadMultipleFiles(Request $request, $fileField, $directory = 'uploads', $disk = 'public')
    {
        $filePaths = [];

        if ($request->hasFile($fileField)) {
            foreach ($request->file($fileField) as $file) {

                $originalName = $file->getClientOriginalName();

                $customFileName = 'Classified' . '_' . time() . '_' . pathinfo($originalName, PATHINFO_FILENAME) . '.' . $file->getClientOriginalExtension();

                $filePaths[] = $file->storeAs($directory, $customFileName, $disk);
            }
        }

        return $filePaths;
    }

}
