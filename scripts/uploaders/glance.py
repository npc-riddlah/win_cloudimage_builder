from buildImageLib import *
from glanceclient import Client

def start(image):
    #Auth
    logger.info(f"Pending to upload: {image.fullImgPath} with name {image.osName}\n")
    loader = loading.get_plugin_loader('password')
    try:
        os.environ['OS_AUTH_URL']
        os.environ['OS_USERNAME']
        os.environ['OS_PASSWORD']
        os.environ['OS_PROJECT_ID']
        os.environ['OS_USER_DOMAIN_NAME']
    except:
        throwError("Check your OpenStack Auth environment variables. Something we do not found. Did you run with sudo?")
    uploadAuth = loader.load_from_options(
        auth_url=os.environ['OS_AUTH_URL'],    #TODO: Exceptions on checks of existance!!!
        username=os.environ['OS_USERNAME'],
        password=os.environ['OS_PASSWORD'],
        project_id=os.environ['OS_PROJECT_ID'],
        user_domain_name=os.environ['OS_USER_DOMAIN_NAME'])
    uploadSession = session.Session(auth=uploadAuth)
    #Create glance client and upload image
    glance = Client('2', session=uploadSession)
    #Todo: Custom properties from config. Do like in image config: [GLANCE.PROPERTIES] and defaults. We can use dict to kwargs conversion to fill glance.images.create properties dynamically from config: glance.images.create(**a) where **a is an "a" dict with parameters like {'hw_disk_bus': 'virtio'} and it will look like hw_disk_bus='virtio'
    osImage = glance.images.create(name=image.osName, disk_format='raw', container_format='bare', hw_disk_bus='virtio', hw_firmware_type='uefi', hw_machine_type='pc-q35-focal-hpb', hw_rescue_bus='virtio', hw_rescue_device='disk', hw_video_model='cirrus', os_type='windows', rdp_type='windows')
    logger.info(f"Image created with ID: {osImage.id}")
    logger.info("Uploading image...")
    sendStatus(f"""💾*Starting upload*💾  
{image.uuid} with name {image.osName} and OpenStackID:```{osImage.id}```""")
    fullUrl=os.environ['OS_AUTH_URL'].removesuffix(':5000')
    #Todo: Progressbar?
    try:
        with open(image.fullImgPath, 'rb') as imgFile:
            glance.images.upload(osImage.id, imgFile)
    except (KeyboardInterrupt, Exception) as error:
        logger.error(f"ERROR:Uploading went wrong. Deleting image {osImage.id}.")
        logger.error(error)
        sendStatus(f"""❌*Uploading failed!*❌  
Error: {error}""")
        exit(1)

    logger.info(f"Uploaded with ID: {osImage.id}")
    sendStatus(f"✅*Uploading done!*✅  {image.uuid} with name {image.osName} uploaded with OpenStackID:```{osImage.id}```")
    image.osImgID=osImage.id
