<?php

namespace App\Http\Controllers\customer\blog;

use App\Http\Controllers\BaseController;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use App\Models\Blog;
use App\Services\ResponseService;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use App\Traits\ImageTrait;

class BlogController extends BaseController
{
    // search filter by category
    public function index(Request $request)
    {
        $searchTerm = $request->query('search');
        $categoryId = $request->query('category');
        $limit = $request->query('limit', 20);

        $query = Blog::query();

        if ($searchTerm) {
            $query->where(function($q) use ($searchTerm) {
                $q->where('blog_title', 'like', '%' . $searchTerm . '%')
                ->orWhere('blog_content', 'like', '%' . $searchTerm . '%')
                ->orWhere('keyword', 'like', '%' . $searchTerm . '%');
            });
        }

        if ($categoryId) {
            $query->where('blog_category_id', $categoryId);
        }

        $moreBlogs = Blog::where(function($q) use ($categoryId) {
            if ($categoryId) {
                $q->where('blog_category_id', '!=', $categoryId);
            }
        })
        ->orderBy('id', 'desc')
        ->limit(5)
        ->get();

        $blogs = $query->orderBy('id', 'desc')->paginate($limit);

        return $this->sendPaginatedResponse2('Blogs retrieved successfully', $blogs, 200, ['moreBlogs' => $moreBlogs->toArray()]);
    }

    // Get single blog
    public function show($slug)
    {
        $blog = Blog::select('id', 'blog_title', 'blog_content', 'blog_category_id', 'blog_thumb_img', 'cover_img', 'keyword', 'slug')
            ->with([
                'blogComments' => function ($query) {
                    $query->select('id', 'comment', 'blog_id', 'user_id', 'created_at')
                        ->with([
                            'getUser' => function ($query) {
                                $query->select('id', 'name', 'profile_img');
                            }
                        ]);
                },
                'category' => function ($query) {
                    $query->select('id', 'name');
                }
            ])
            ->where('slug', $slug)
            ->first();

        if (!$blog) {
            return $this->sendErrorResponse('Blog not found', 404);
        }

        $moreBlogs = Blog::select('id', 'blog_title', 'slug', 'blog_thumb_img', 'created_at')
            ->where('blog_category_id', $blog->blog_category_id)
            ->where('id', '!=', $blog->id)
            ->latest()
            ->take(5)
            ->get();

        if ($moreBlogs->isEmpty()) {
            $moreBlogs = Blog::select('id', 'blog_title', 'slug', 'blog_thumb_img', 'created_at')
                ->where('id', '!=', $blog->id)
                ->inRandomOrder()
                ->take(5)
                ->get();
        }

        return $this->sendSuccessResponse('Retrieved', [
            'blog' => $blog,
            'more_blogs' => $moreBlogs
        ]);
    }


    // Get blogs by category
    public function getByCategory(Request $request, $id)
    {
        $limit = $request->query('limit', 20);

        $blogs = Blog::select('id', 'blog_title', 'blog_content', 'blog_category_id', 'blog_thumb_img', 'cover_img', 'keyword', 'slug')
            ->where('blog_category_id', $id)
            ->orderBy('id', 'desc')
            ->paginate($limit);

        return $this->sendPaginatedResponse('Blogs retrieved successfully', $blogs);
    }

    //search
    public function search(Request $request)
    {
        $searchTerm = $request->query('search');
        $limit = $request->query('limit', 20);

        if (!$searchTerm) {
            return ResponseService::error('Search term is required');
        }

        $blogs = Blog::where('blog_title', 'like', '%' . $searchTerm . '%')
            ->orWhere('blog_content', 'like', '%' . $searchTerm . '%')
            ->orWhere('keyword', 'like', '%' . $searchTerm . '%')
            ->paginate($limit);

        return $this->sendPaginatedResponse('Blogs retrieved successfully', $blogs);
    }
}
