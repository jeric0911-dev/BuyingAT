"use client";

import { editProduct } from "@/actions/product";
import { success } from "@/constants";
import getParsedJson from "@/utils/getParsedJson";
import objectToFormData from "@/utils/objectToFormData";
import Image from "next/image";
import { useEffect, useState } from "react";
import { useFieldArray, useForm } from "react-hook-form";
import { toast } from "sonner";
import ColorSection from "./ColorSection";
import SizeSection from "./SizeSection";
import SpecificationSection from "./SpecificationSection";
import AdditionalInfoSection from "./AdditionalInfoSection";
import VariationSection from "./VariationSection";

const featureList = [
  { id: 0, name: "Allow product Colors" },
  { id: 1, name: "Allow product Size" },
  { id: 2, name: "Allow product Specification" },
  { id: 3, name: "Allow product Additional Info" },
  { id: 4, name: "Allow product Variant" },
];

const EditProductForm = ({ categories, subCategories, brands, data }) => {
  const [loading, setLoading] = useState(false);
  const [list, setList] = useState({});
  const [selectedImages, setSelectedImages] = useState([]);

  useEffect(() => {
    const initialList = {};
    if (data?.colors?.length > 0) initialList[0] = "0";
    if (data?.sizes?.length > 0) initialList[1] = "1";
    const additional_info = data.additional_info;
    if (
      additional_info?.specification &&
      getParsedJson(additional_info?.specification)?.length > 0
    )
      initialList[2] = "2";
    if (
      additional_info?.additional_info &&
      getParsedJson(additional_info?.additional_info)?.length > 0
    )
      initialList[3] = "3";
    if (data?.variants?.length > 0) initialList[4] = "4";
    setList(initialList);
  }, [data]);

  const handleImageChange = (e) => {
    const newImages = [...selectedImages, ...e.target.files];
    setSelectedImages(newImages.slice(0, 6));
  };
  const handleDeleteImage = (index) => {
    const updatedImages = selectedImages.filter((_, i) => i !== index);
    setSelectedImages(updatedImages);
  };

  const { register, handleSubmit, control, watch, setValue } = useForm({
    defaultValues: {
      product_title: data?.product_title,
      category_id: data?.category_id,
      sub_category_id: data?.sub_category_id,
      product_description: data?.product_description,
      brand_id: data?.brand_id || "",
      stock: data?.stock,
      price: data?.price,
      discounted_price: data?.discounted_price,
      shipping_class: data?.shipping_class,
      delivery_time: data?.delivery_time,
      colors: data?.colors || [],
      sizes: data?.sizes || [],
      specification:
        getParsedJson(data?.additional_info?.specification)?.map((item) => {
          const [key, value] = Object.entries(item)[0];
          return { key, value };
        }) || [],
      additional_info_json:
        getParsedJson(data?.additional_info?.additional_info)?.map((item) => {
          const [key, value] = Object.entries(item)[0];
          return { key, value };
        }) || [],
      variations: data?.variants || [],
    },
  });

  const {
    fields: colorFields,
    append: appendColor,
    remove: removeColor,
  } = useFieldArray({
    name: "colors",
    control,
  });

  const {
    fields: sizeFields,
    append: appendSize,
    remove: removeSize,
  } = useFieldArray({
    name: "sizes",
    control,
  });

  const {
    fields: specFields,
    append: appendSpec,
    remove: removeSpec,
  } = useFieldArray({
    name: "specification",
    control,
  });

  const {
    fields: aiFields,
    append: appendAi,
    remove: removeAi,
  } = useFieldArray({
    name: "additional_info_json",
    control,
  });

  const {
    fields: vrFields,
    append: appendVr,
    remove: removeVr,
  } = useFieldArray({
    name: "variations",
    control,
  });

  const filteredSubCategories = subCategories?.filter(
    (item) => item.category_id == watch("category_id")
  );

  const onSubmit = async (values) => {
    setLoading(true);
    const toastId = toast.loading("Loading...");
    try {
      values.specification =
        values.specification?.length > 0
          ? values.specification.map((item) => ({
              [item.key]: item.value,
            }))
          : [];
      values.additional_info_json =
        values.additional_info_json?.length > 0
          ? values.additional_info_json.map((item) => ({
              [item.key]: item.value,
            }))
          : [];
      values.colors?.length > 0
        ? values.colors.forEach(
            (c, i) => ((values[`colors${i}`] = c.image), delete c.image)
          )
        : [];
      const res = await editProduct(
        data.id,
        objectToFormData({ ...values, img: selectedImages })
      );
      if (res.status === success) {
        toast.success(res.message, { id: toastId });
      } else {
        toast.error(res.error || "Something went wrong!", { id: toastId });
      }
    } catch (error) {
      toast.error("Failed to add product", { id: toastId });
      // console.log(error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <label className="block mt-6 text-sm">
        Title
        <input
          {...register("product_title")}
          type="text"
          className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
          placeholder="Listing title"
          required
        />
      </label>
      <label className="block mt-4 text-sm">
        Category
        <select
          {...register("category_id")}
          className="mt-2 h-11 w-full border border-border rounded-sm form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm"
          required
        >
          <option value="">Select</option>
          {categories?.map((item, i) => (
            <option key={i} value={item.id}>
              {item.category_name}
            </option>
          ))}
        </select>
      </label>
      <label className="block mt-4 text-sm">
        Sub Category
        <select
          {...register("sub_category_id")}
          className="mt-2 h-11 w-full border border-border rounded-sm form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm"
          required
        >
          <option value="">Select</option>
          {filteredSubCategories?.map((item, i) => (
            <option key={i + 1} value={item.id}>
              {item.sub_category_name}
            </option>
          ))}
        </select>
      </label>
      <p className="mt-4 text-sm">Product Images (Max. 6)</p>
      <div className="flex flex-wrap gap-3 mt-2 border border-border rounded-sm p-2">
        {selectedImages.map((image, index) => (
          <div key={index} className="rounded relative group">
            <Image
              src={URL.createObjectURL(image)}
              alt="#"
              width={0}
              height={0}
              sizes="100vw"
              className="h-[88px] !w-auto rounded"
            />
            <div className="absolute inset-0 rounded bg-black/0 group-hover:bg-black/40 transition-all flex justify-center items-center">
              <Image
                onClick={() => handleDeleteImage(index)}
                src="/icon/deleteIconBlue.svg"
                alt="#"
                width={34}
                height={34}
                className="opacity-0 group-hover:opacity-100 transition-all"
              />
            </div>
          </div>
        ))}
        {selectedImages.length < 6 && (
          <label htmlFor="productImages" className="cursor-pointer">
            <input
              id="productImages"
              type="file"
              multiple
              accept="image/*"
              onChange={(e) => {
                handleImageChange(e);
              }}
              className="sr-only"
            />
            <div className="h-[88px] w-[135px] rounded-sm bg-skyBlue/5 border border-skyBlue flex justify-center items-center">
              <Image src="/icon/plusBlue.svg" alt="#" width={34} height={34} />
            </div>
          </label>
        )}
      </div>
      <label className="block mt-4 text-sm">
        Description
        <textarea
          {...register("product_description")}
          className="mt-2 h-36 w-full border border-border rounded-sm px-4 form-textarea focus:ring-0 focus:border-skyBlue text-sm"
          placeholder="Add description"
          required
        />
      </label>
      <label className="block mt-6 text-sm">
        Brand
        <select
          {...register("brand_id")}
          className="mt-2 h-11 w-full border border-border rounded-sm form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm"
        >
          <option value="">Select</option>
          {brands
            ?.filter((item) => item.category_id == watch("category_id"))
            ?.map((item, i) => (
              <option key={i + 1} value={item.id}>
                {item.brand_name}
              </option>
            ))}
        </select>
      </label>
      <p className="mt-10">Add More Information</p>
      <div className="grid grid-cols-2 lg:grid-cols-4 mt-2">
        {featureList.map((item) => (
          <label
            key={item.id}
            className="text-sm text-tGray flex items-center gap-2 mt-3"
          >
            <input
              onChange={(e) => {
                setList((prevList) => {
                  const newList = { ...prevList };
                  if (e.target.checked) {
                    newList[e.target.value] = e.target.value;
                  } else {
                    delete newList[e.target.value];
                    e.target.value == 0
                      ? setValue("colors", "")
                      : e.target.value == 1
                      ? setValue("sizes", "")
                      : e.target.value == 2
                      ? setValue("specification", "")
                      : e.target.value == 3
                      ? setValue("additional_info_json", "")
                      : "";
                  }

                  return newList;
                });
              }}
              type="checkbox"
              className="form-checkbox border-border text-skyBlue focus:ring-0"
              value={item.id}
              checked={item.id in list}
            />
            {item.name}
          </label>
        ))}
      </div>
      {list[0] && (
        <ColorSection
          colorFields={colorFields}
          register={register}
          appendColor={appendColor}
          removeColor={removeColor}
        />
      )}
      {list[1] && (
        <SizeSection
          sizeFields={sizeFields}
          register={register}
          appendSize={appendSize}
          removeSize={removeSize}
        />
      )}
      {list[2] && (
        <SpecificationSection
          specFields={specFields}
          register={register}
          appendSpec={appendSpec}
          removeSpec={removeSpec}
        />
      )}
      {list[3] && (
        <AdditionalInfoSection
          aiFields={aiFields}
          register={register}
          appendAi={appendAi}
          removeAi={removeAi}
        />
      )}
      {list[4] && (
        <VariationSection
          vrFields={vrFields}
          register={register}
          appendVr={appendVr}
          removeVr={removeVr}
        />
      )}

      {list[0] || list[1] || list[4] ? null : (
        <div className="grid grid-cols-2 gap-5 lg:gap-16">
          <label className="block mt-6 text-sm">
            Stock
            <input
              {...register("stock")}
              type="number"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="1"
              required
            />
          </label>
        </div>
      )}
      <p className="px-6 py-4 border border-border rounded text-sm font-medium my-6">
        PRODUCT PRICE
      </p>
      <div className="grid grid-cols-2 gap-5 lg:gap-16">
        <label className="block text-sm">
          Price
          <div className="flex mt-2">
            <div className="h-11 px-5 bg-lightGray border border-border border-r-0 rounded-l-sm leading-[44px]">
              $
            </div>
            <input
              {...register("price")}
              type="number"
              className="h-11 w-full border border-border border-l-0 rounded-sm rounded-l-none px-4 form-input focus:ring-0 focus:border-border text-sm"
              placeholder="0.00"
              required
            />
          </div>
        </label>
        <label className="block text-sm">
          Discounted Price
          <div className="flex mt-2">
            <div className="h-11 px-5 bg-lightGray border border-border border-r-0 rounded-l-sm leading-[44px]">
              $
            </div>
            <input
              {...register("discounted_price")}
              type="number"
              className="h-11 w-full border border-border border-l-0 rounded-sm rounded-l-none px-4 form-input focus:ring-0 focus:border-border text-sm"
              placeholder="0.00"
            />
          </div>
        </label>
      </div>
      <p className="px-6 py-4 border border-border rounded text-sm font-medium my-6">
        SHIPPING
      </p>
      <div className="grid grid-cols-2 gap-5 lg:gap-16">
        <label className="block text-sm">
          Shipping class
          <select
            {...register("shipping_class")}
            className="mt-2 h-11 w-full border border-border rounded-sm form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm"
          >
            <option value="popular">Most Recent</option>
            <option value="newest">Lowest Price</option>
            <option value="oldest">Highest Price</option>
            <option value="low">Highest Rating</option>
          </select>
        </label>
        <label className="block text-sm">
          Delivery Time
          <select
            {...register("delivery_time")}
            className="mt-2 h-11 w-full border border-border rounded-sm form-select focus:ring-0 focus:border-skyBlue text-tGray text-sm"
          >
            <option value="popular">Most Recent</option>
            <option value="newest">Lowest Price</option>
            <option value="oldest">Highest Price</option>
            <option value="low">Highest Rating</option>
          </select>
        </label>
      </div>
      <div className="flex justify-end items-center mt-6">
        {/* <button type="button" className="bg-black text-white px-8 py-3 text-xs font-bold rounded-sm">
          BACK
        </button> */}
        <button
          type="submit"
          className="bg-skyBlue text-white px-8 py-3 text-xs font-bold rounded-sm"
          disabled={loading}
        >
          SUBMIT
        </button>
      </div>
    </form>
  );
};

export default EditProductForm;
