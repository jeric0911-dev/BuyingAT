<?php

namespace App\Http\Controllers\admin\morePage;

use App\Http\Controllers\BaseController;
use App\Models\MorePage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class MorePageController extends BaseController
{
    // Get all pages
    public function index()
    {
        $pages = MorePage::all();
        return $this->sendSuccessResponse('Pages retrieved successfully', $pages);
    }

    // Get one page by slug
    public function show($slug)
    {
        $page = MorePage::where('slug', $slug)->firstOrFail();
        return $this->sendSuccessResponse('Page retrieved successfully', $page);
    }

    // Store a new page
    public function store(Request $request)
    {
        $data = $request->validate([
            'title'   => 'required|string',
            'banner'  => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'content' => 'required|string',
        ]);

        $data['slug'] = Str::slug($data['title']);

        if ($request->hasFile('banner')) {
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'morePage_banner');
        }

        $page = MorePage::create($data);

        return $this->sendSuccessResponse('More Page created successfully', $page, 201);
    }

    // Update an existing page
    public function update(Request $request, $id)
    {
        $data = $request->validate([
            'title'   => 'required|string',
            'banner'  => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'content' => 'required|string',
        ]);

        $page = MorePage::findOrFail($id);

        $data['slug'] = Str::slug($data['title']);

        if ($request->hasFile('banner')) {
            if ($page->banner) {
                Storage::disk('public')->delete($page->banner);
            }
            $data['banner'] = $this->compressAndUploadImage($request->file('banner'), 'morePage_banner');
        }

        $page->update($data);

        return $this->sendSuccessResponse('More Page updated successfully', $page);
    }

    // Delete a page
    public function destroy($id)
    {
        $page = MorePage::findOrFail($id);

        if ($page->banner) {
            Storage::disk('public')->delete($page->banner);
        }

        $page->delete();

        return $this->sendSuccessResponse('Page deleted successfully');
    }
}
