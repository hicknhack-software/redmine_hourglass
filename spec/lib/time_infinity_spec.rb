require_relative '../spec_helper'
describe Chronos::TimeInfinity do

  context 'positive value' do
    let (:infinity) { Chronos::TimeInfinity.new }

    it 'is greater as an arbitrary Time value' do
      expect(infinity > Time.now).to be true
      expect(Time.now < infinity).to be true
    end

    it 'is greater equals an arbitrary Time value' do
      expect(infinity >= Time.now).to be true
      expect(Time.now <= infinity).to be true
    end

    it 'is not equals an arbitrary Time value' do
      expect(infinity == Time.now).to be false
      expect(Time.now == infinity).to be false
      expect(infinity != Time.now).to be true
      expect(Time.now != infinity).to be true
    end

    it 'is not smaller as an arbitrary Time value' do
      expect(infinity < Time.now).to be false
      expect(Time.now > infinity).to be false
    end

    it 'is not smaller equals an arbitrary Time value' do
      expect(infinity <= Time.now).to be false
      expect(Time.now >= infinity).to be false
    end
  end

  context 'negative value' do
    let (:negative_infinity) { Chronos::TimeInfinity.new(-1) }

    it 'is not greater as an arbitrary Time value' do
      expect(negative_infinity > Time.now).to be false
      expect(Time.now < negative_infinity).to be false
    end

    it 'is not greater equals an arbitrary Time value' do
      expect(negative_infinity >= Time.now).to be false
      expect(Time.now <= negative_infinity).to be false
    end

    it 'is not equals an arbitrary Time value' do
      expect(negative_infinity == Time.now).to be false
      expect(Time.now == negative_infinity).to be false
      expect(negative_infinity != Time.now).to be true
      expect(Time.now != negative_infinity).to be true
    end

    it 'is smaller as an arbitrary Time value' do
      expect(negative_infinity < Time.now).to be true
      expect(Time.now > negative_infinity).to be true
    end

    it 'is smaller equals an arbitrary Time value' do
      expect(negative_infinity <= Time.now).to be true
      expect(Time.now >= negative_infinity).to be true
    end
  end
end
