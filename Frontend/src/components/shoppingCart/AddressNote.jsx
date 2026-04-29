"use client";

import updateQueryParam from "@/utils/updateQueryParam";

const AddressNote = () => {
  return (
    <section>
      <div>
        <p className="text-lg font-medium">Shipping Information</p>
        {/* <div className="flex flex-col sm:flex-row gap-4 mt-6">
          <div className="flex items-end gap-4 w-full sm:w-1/2">
            <label className="block text-sm w-1/2">
              User name
              <input
                type="text"
                className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
                placeholder="First name"
              />
            </label>
            <label className="block text-sm w-1/2">
              <input
                type="text"
                className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
                placeholder="Last name"
              />
            </label>
          </div>

          <div className="w-full sm:w-1/2">
            <label className="block text-sm">
              Company Name <span className="text-tGray">(Optional)</span>
              <input
                type="text"
                className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
                placeholder="First name"
              />
            </label>
          </div>
        </div> */}

        <div className="mt-4">
          <label className="block text-sm">
            Address
            <input
              onChange={(e) => updateQueryParam("address", e.target.value)}
              type="text"
              className="mt-2 input-input"
              placeholder="area, road, house"
            />
          </label>
        </div>

        {/* <div className="mt-4 flex sm:flex-row flex-col gap-4">
          <label className="block text-sm w-full sm:w-1/4">
            Country
            <select
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Select..."
            >
              <option>Select...</option>
            </select>
          </label>
          <label className="block text-sm w-full sm:w-1/4">
            Region/State
            <select
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Select..."
            >
              <option>Select...</option>
            </select>
          </label>
          <label className="block text-sm w-full sm:w-1/4">
            City
            <select
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-select focus:ring-0 focus:border-skyBlue text-sm"
              placeholder="Select..."
            >
              <option>Select...</option>
            </select>
          </label>
          <label className="block text-sm w-full sm:w-1/4">
            Zip Code
            <input
              type="number"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            />
          </label>
        </div>

        <div className="mt-4 flex sm:flex-row flex-col gap-4">
          <label className="block text-sm w-full sm:w-1/2">
            Email
            <input
              type="email"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            />
          </label>
          <label className="block text-sm w-full sm:w-1/2">
            Phone Number
            <input
              type="number"
              className="mt-2 h-11 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            />
          </label>
        </div> */}
        {/* <label className="text-sm text-[#475156] flex items-center gap-2 mt-6">
          <input
            type="checkbox"
            className="form-checkbox border-border rounded-sm text-skyBlue focus:ring-0"
          />
          Ship into different address
        </label> */}
      </div>
      <div className="mt-10">
        <p className="text-lg font-medium">Payment Option</p>
        <label className="block text-sm mt-6">
          Payment Method
          <select className="mt-2 input-select">
            <option value="">Cash on Delivery</option>
          </select>
        </label>
      </div>

      <div className="mt-10">
        <p className="text-lg font-medium">Additional Information</p>
        <label className="block text-sm mt-6">
          Order Notes <span className="text-tGray">(Optional)</span>
          <textarea
            onChange={(e) => updateQueryParam("note", e.target.value)}
            className="mt-2 h-28 w-full border border-border rounded-sm px-4 form-input focus:ring-0 focus:border-skyBlue text-sm"
            placeholder="Notes about your order, e.g. special notes for delivery"
          />
        </label>
      </div>
    </section>
  );
};

export default AddressNote;
