import React from 'react';
import Product from './Product';
import PropTypes from 'prop-types';

function ProductList(props) {
    
    return (
        <React.Fragment>
            <div className='container' id="products">
                <div className="row pdg-line">
                    <div className="col-4 col-sm-4 col-md-4">
                        <div className="abt-top-border"> </div>
                    </div>
                    <div className="col-4 col-sm-4 col-md-4">
                        <p className="product-title text-center">PRODUCTS </p>
                    </div>
                    <div className="col-4 col-sm-4 col-md-4">
                        <div className="abt-top-border"> </div>
                    </div>
                </div>
                
                <div className="men-products">
                    <div className="row">
                        {/* The fix is below: Array.isArray checks if the list exists before mapping */}
                        {Array.isArray(props.productList) && props.productList.map((product) =>
                            <Product 
                                whenProductClicked={props.onProductSelection} 
                                photo={product.photo}
                                name={product.name}
                                price={product.price}
                                id={product._id}
                                key={product._id}
                            />
                        )}
                    </div>
                </div>
            </div>
        </React.Fragment>
    );
}

ProductList.propTypes = {
    productList: PropTypes.array,
    onProductSelection: PropTypes.func,
};

export default ProductList;