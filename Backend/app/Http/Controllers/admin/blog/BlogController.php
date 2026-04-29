<?php

namespace App\Http\Controllers\admin\blog;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use App\Models\Blog;
use App\Services\ResponseService;
use App\Traits\ImageTrait;

class BlogController extends BaseController
{
    use ImageTrait;

    // Get all blogs
    public function index()
    {
        $blogs = Blog::all();
        return $this->sendSuccessResponse('Retrieved', $blogs);
    }

    // Store blog
    public function store(Request $request)
    {
        $data = $request->validate([
            'blog_title' => 'required|string|max:255',
            'blog_content' => 'required|string',
            'blog_category_id' => 'required|exists:blog_categories,id',
            'blog_thumb_img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'cover_img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'keyword' => 'required|string',
            'meta_tag' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:1000',
            'status' => 'nullable|integer',
        ]);

        $slug = Str::slug($request->blog_title) . '_' . str_pad(mt_rand(1, 999), 3, '0', STR_PAD_LEFT);
        $data['slug'] = $slug;
        $data['status'] = $data['status'] ?? 1;

        if ($request->hasFile('blog_thumb_img')) {
            $data['blog_thumb_img'] = $this->compressAndUploadImage($request->file('blog_thumb_img'), 'blog_images');
        }

        if ($request->hasFile('cover_img')) {
            $data['cover_img'] = $this->compressAndUploadImage($request->file('cover_img'), 'blog_images');
        }

        $blog = Blog::create($data);

        return $this->sendSuccessResponse('Created', $blog, 201);
    }

    // Get single blog
    public function show($id)
    {
        $blog = Blog::findOrFail($id);
        return $this->sendSuccessResponse('Retrieved', $blog);
    }

    // Update blog
    public function update(Request $request, $id)
    {
        Log::info('Incoming Blog Update Request', [
            'data' => $request->all(),
            'files' => $request->allFiles(),
            'ip' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        $blog = Blog::findOrFail($id);

        $data = $request->validate([
            'blog_title' => 'required|string|max:255',
            'blog_content' => 'required|string',
            'blog_category_id' => 'required|exists:blog_categories,id',
            'blog_thumb_img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'cover_img' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp,avif|max:2048',
            'keyword' => 'required|string',
            'meta_tag' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:1000',
            'status' => 'nullable|integer',
        ]);

        $data['slug'] = Str::slug($request->blog_title) . '_' . str_pad(mt_rand(1, 999), 3, '0', STR_PAD_LEFT);
        $data['status'] = $data['status'] ?? $blog->status;

        if ($request->hasFile('blog_thumb_img')) {
            if ($blog->blog_thumb_img) {
                Storage::disk('public')->delete($blog->blog_thumb_img);
            }
            $data['blog_thumb_img'] = $this->compressAndUploadImage($request->file('blog_thumb_img'), 'blog_images');
        }

        if ($request->hasFile('cover_img')) {
            if ($blog->cover_img) {
                Storage::disk('public')->delete($blog->cover_img);
            }
            $data['cover_img'] = $this->compressAndUploadImage($request->file('cover_img'), 'blog_images');
        }

        $blog->update($data);

        return $this->sendSuccessResponse('Updated', $blog->fresh());
    }

    // Delete blog
    public function destroy($id)
    {
        $blog = Blog::findOrFail($id);

        if (!$blog) {
            return $this->sendErrorResponse('Blog not found', 404);
        }

        if ($blog->blog_thumb_img) {
            Storage::disk('public')->delete($blog->blog_thumb_img);
        }

        if ($blog->cover_img) {
            Storage::disk('public')->delete($blog->cover_img);
        }

        $blog->delete();

        return $this->sendSuccessResponse('Deleted', null);
    }
}
