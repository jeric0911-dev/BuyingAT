"use client";

import { addProduct } from "@/actions/product";
import { success } from "@/constants";
import objectToFormData from "@/utils/objectToFormData";
import Image from "next/image";
import { useState } from "react";
import { useForm, useFieldArray } from "react-hook-form";
import { toast } from "sonner";
import ColorSection from "./ColorSection";
import SizeSection from "./SizeSection";
import SpecificationSection from "./SpecificationSection";
import AdditionalInfoSection from "./AdditionalInfoSection";
import VariationSection from "./VariationSection";
import { useTransitionRouter } from "next-view-transitions";

const featureList = [
  { id: 0, name: "Allow product Colors" },
  { id: 1, name: "Allow product Size" },
  { id: 2, name: "Allow product Specification" },
  { id: 3, name: "Allow product Additional Info" },
  { id: 4, name: "Allow product Variant" },
];

const AddProductForm = ({ categories, subCategories, brands }) => {
  const [loading, setLoading] = useState(false);
  const [list, setList] = useState({});
  const [selectedImages, setSelectedImages] = useState([]);
  const router = useTransitionRouter()

  const handleImageChange = (e) => {
    const newImages = [...selectedImages, ...e.target.files];
    setSelectedImages(newImages.slice(0, 6));
  };
  const handleDeleteImage = (index) => {
    const updatedImages = selectedImages.filter((_, i) => i !== index);
    setSelectedImages(updatedImages);
  };

  const {
    register,
    handleSubmit,
    control,
    watch,
    setValue,
    formState: { errors },
  } = useForm({
    mode: 'onChange',
    defaultValues: {
      product_title: "",
      category_id: "",
      sub_category_id: "",
      product_description: "",
      brand_id: "",
      // stock: "",
      price: "",
      discounted_price: "",
      shipping_class: "",
      delivery_time: "",
      colors: [],
      sizes: [],
      specification: [],
      additional_info_json: [],
      variations: [],
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
      const res = await addProduct(
        objectToFormData({ ...values, img: selectedImages })
      );
      if (res.status === success) {
        toast.success(res.message, { id: toastId });
        router.push("/");
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
          className="mt-2 input-input"
          placeholder="Listing title"
          required
        />
      </label>
      <label className="block mt-4 text-sm">
        Category
        <select
          {...register("category_id")}
          className="mt-2 input-select"
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
          className="mt-2 input-select"
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
              required
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
          className="mt-2 h-36 input-base form-textarea"
          placeholder="Add description"
          required
        />
      </label>
      <label className="block mt-6 text-sm">
        Brand
        <select {...register("brand_id")} className="mt-2 input-select">
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
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 mt-2">
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
              className="mt-2 input-input"
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
              className="input-input border-l-0 rounded-l-none"
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
              {...register("discounted_price", {
                validate: (value, formValues) =>
                  !value ||
                  parseFloat(value) <= parseFloat(formValues.price) ||
                  "Discounted price must be less than or equal to main price",
              })}
              type="number"
              className="input-input border-l-0 rounded-l-none"
              placeholder="0.00"
            />
          </div>
          {errors.discounted_price && (
            <p className="text-red-500 text-xs mt-1">
              {errors.discounted_price.message}
            </p>
          )}
        </label>
      </div>
      <p className="px-6 py-4 border border-border rounded text-sm font-medium my-6">
        SHIPPING
      </p>
      <div className="grid grid-cols-2 gap-5 lg:gap-16">
        <label className="block text-sm">
          Shipping class
          <select {...register("shipping_class")} className="mt-2 input-select">
            <option value="standard">Standard</option>
            <option value="express">Express</option>
            <option value="overnight">Overnight</option>
            <option value="same_day">Same Day</option>
            <option value="economy">Economy</option>
          </select>
        </label>
        <label className="block text-sm">
          Delivery Time
          <select {...register("delivery_time")} className="mt-2 input-select">
            <option value="1">1 Day</option>
            <option value="2">Up to 2 Days</option>
            <option value="3">Up to 3 Days</option>
            <option value="more">More Than 3 Days</option>
          </select>
        </label>
      </div>
      <div className="flex justify-between items-center mt-6">
        <button className="bg-black text-white px-8 py-3 text-xs font-bold rounded-sm">
          BACK
        </button>
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

export default AddProductForm;
