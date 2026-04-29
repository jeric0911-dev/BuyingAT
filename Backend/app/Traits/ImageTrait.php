<?php

namespace App\Traits;

use Illuminate\Support\Facades\Storage;
use Exception;

trait ImageTrait
{
    protected function handleUploadedFile($file, $directory)
    {
        if ($file && $file->isValid()) {
            $filePath = $file->store($directory, 'public');
            return $filePath;
        }
        return null;
    }

    protected function compressAndUploadImage($file, $directory, $maxSizeKB = 100) {
        try {
            $imagePath = $this->handleUploadedFile($file, $directory);
            if (!$imagePath) {
                return null;
            }

            $absolutePath = storage_path('app/public/' . $imagePath);

            if (!$this->resizeAndCompressImage($absolutePath, $maxSizeKB)) {
                return $imagePath;
            }

            return $imagePath;
        } catch (\Exception $e) {

            return $this->handleUploadedFile($file, $directory);
        }
    }

    protected function resizeAndCompressImage($filepath, $maxSizeKB) {
        try {
            // Check if GD extension is available
            if (!extension_loaded('gd')) {
                return false; // Return false if GD is not available
            }

            $extension = strtolower(pathinfo($filepath, PATHINFO_EXTENSION));

            switch ($extension) {
                case 'jpeg':
                case 'jpg':
                    if (!function_exists('imagecreatefromjpeg')) {
                        return false;
                    }
                    $image = imagecreatefromjpeg($filepath);
                    break;
                case 'png':
                    if (!function_exists('imagecreatefrompng')) {
                        return false;
                    }
                    $image = imagecreatefrompng($filepath);
                    break;
                case 'gif':
                    if (!function_exists('imagecreatefromgif')) {
                        return false;
                    }
                    $image = imagecreatefromgif($filepath);
                    break;
                default:
                    return false;
            }

            //Get the original image dimensions
            $width = imagesx($image);
            $height = imagesy($image);

            // Resize to reduce the image dimensions if it's too large
            if ($width > 1024 || $height > 1024) {
                $resizeFactor = 1024 / max($width, $height);
                $newWidth = floor($width * $resizeFactor);
                $newHeight = floor($height * $resizeFactor);
            } else {
                $newWidth = $width;
                $newHeight = $height;
            }

            // Create a new image resource for the resized image
            $resizedImage = imagecreatetruecolor($newWidth, $newHeight);

            // Handle transparency for PNG
            if ($extension === 'png') {
                imagealphablending($resizedImage, false);
                imagesavealpha($resizedImage, true);
                $transparent = imagecolorallocatealpha($resizedImage, 255, 255, 255, 127);
                imagefilledrectangle($resizedImage, 0, 0, $newWidth, $newHeight, $transparent);
            }

            // Copy the resized image into the new image resource
            imagecopyresampled($resizedImage, $image, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

            //Compress the image to ensure it is under 100 KB
            $quality = 80;
            $tempPath = $filepath . '.temp';

            do {
                if (in_array($extension, ['jpeg', 'jpg'])) {
                    imagejpeg($resizedImage, $tempPath, $quality);
                } elseif ($extension === 'png') {
                    $compressionLevel = floor((100 - $quality) / 10);
                    imagepng($resizedImage, $tempPath, $compressionLevel);
                }

                $fileSize = filesize($tempPath);
                $quality -= 5;
            } while ($fileSize > $maxSizeKB * 1024 && $quality > 10);

            // If still too large after quality reduction, resize further
            if ($fileSize > $maxSizeKB * 1024 && $quality <= 10) {
                $newWidth = floor($newWidth * 0.8);
                $newHeight = floor($newHeight * 0.8);

                $resizedImage = imagecreatetruecolor($newWidth, $newHeight);

                // Handle transparency for PNG
                if ($extension === 'png') {
                    imagealphablending($resizedImage, false);
                    imagesavealpha($resizedImage, true);
                    $transparent = imagecolorallocatealpha($resizedImage, 255, 255, 255, 127);
                    imagefilledrectangle($resizedImage, 0, 0, $newWidth, $newHeight, $transparent);
                }

                // Reapply resizing
                imagecopyresampled($resizedImage, $image, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

                // Re-save the image with a lower quality setting
                if (in_array($extension, ['jpeg', 'jpg'])) {
                    imagejpeg($resizedImage, $tempPath, 60);
                } elseif ($extension === 'png') {
                    imagepng($resizedImage, $tempPath, 8);
                }
            }

            if (file_exists($tempPath) && filesize($tempPath) < filesize($filepath)) {
                rename($tempPath, $filepath);
            } else {
                unlink($tempPath);
            }

            //Clean up resources
            imagedestroy($image);
            imagedestroy($resizedImage);

            return true;
        } catch (\Exception $e) {
            return false;
        }

    }

    protected function deleteFile($filePath) {
        if ($filePath) {
            Storage::disk('public')->delete($car->titleImage->title_img);
        }
    }
}
